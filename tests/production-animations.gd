extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var host := Node2D.new()
	root.add_child(host)
	current_scene = host

	var player_scene := load("res://game/player/player.tscn") as PackedScene
	_check(player_scene != null, "Player scene loads")
	if player_scene == null:
		_finish()
		return

	var floor := StaticBody2D.new()
	var floor_collision := CollisionShape2D.new()
	var floor_shape := RectangleShape2D.new()
	floor_shape.size = Vector2(200.0, 20.0)
	floor_collision.shape = floor_shape
	floor.add_child(floor_collision)
	floor.position = Vector2(0.0, 10.0)
	host.add_child(floor)

	var player := player_scene.instantiate() as PlayerGirl
	host.add_child(player)
	await physics_frame
	await physics_frame
	_check(player.is_on_floor(), "Player settles on the test floor")

	var player_frames := player.character_sprite.sprite_frames
	for animation_name in [&"fire", &"reload", &"hurt", &"faint"]:
		_check_single_frame_animation(player_frames, animation_name)

	var starting_ammo := player.ammo
	player._try_fire()
	_check(player.ammo == starting_ammo - 1, "Firing consumes one round")
	_check(player.fire_animation_timer > 0.0, "Firing starts the fire animation timer")
	player._update_animation(0.0)
	_check(player.character_sprite.animation == &"fire", "Fire state has animation priority")

	player.ammo = 0
	player.reload()
	_check(player.is_reloading, "Reload starts when the magazine is not full")
	_check(player.ammo == 0, "Reload does not refill before its timer completes")
	player._update_animation(0.0)
	_check(player.character_sprite.animation == &"reload", "Reload state plays reload animation")
	player._update_action_timers(player.reload_duration)
	_check(not player.is_reloading, "Reload ends after its duration")
	_check(player.ammo == player.magazine_size, "Reload refills the magazine on completion")

	player.ammo = 0
	player.reload()
	player.take_damage(1)
	_check(not player.is_reloading, "Taking damage interrupts reload")
	_check(player.hurt_animation_timer > 0.0, "Damage starts the hurt animation timer")
	player._update_animation(0.0)
	_check(player.character_sprite.animation == &"hurt", "Hurt state has animation priority")

	player.take_damage(player.health)
	_check(player.is_dead, "Lethal damage marks the player dead")
	_check(player.character_sprite.animation == &"faint", "Lethal damage plays faint animation")

	var zombie_scene := load("res://game/enemies/zombie.tscn") as PackedScene
	_check(zombie_scene != null, "Courier zombie scene loads")
	if zombie_scene != null:
		var zombie := zombie_scene.instantiate() as ZombieEnemy
		host.add_child(zombie)
		await process_frame
		for animation_name in [&"idle", &"attack", &"hurt", &"faint"]:
			_check_single_frame_animation(zombie.character_sprite.sprite_frames, animation_name, false)
		var zombie_frames := zombie.character_sprite.sprite_frames
		_check(zombie_frames.has_animation(&"walk"), "walk animation exists")
		if zombie_frames.has_animation(&"walk"):
			_check(zombie_frames.get_frame_count(&"walk") == 6, "walk animation has six frames")
			for frame_index in range(zombie_frames.get_frame_count(&"walk")):
				var walk_texture := zombie_frames.get_frame_texture(&"walk", frame_index)
				_check(walk_texture != null, "walk frame %d texture loads" % frame_index)
				if walk_texture != null:
					_check(walk_texture.get_size() == Vector2(256.0, 256.0), "walk frame %d is 256x256" % frame_index)
		zombie._update_facing(-10.0)
		_check(zombie.character_sprite.flip_h, "Right-authored courier mirrors toward a player on the left")
		zombie._update_facing(10.0)
		_check(not zombie.character_sprite.flip_h, "Right-authored courier displays as-is toward a player on the right")
		zombie.velocity.x = zombie.move_speed
		zombie._update_animation()
		_check(zombie.character_sprite.animation == &"walk", "Moving zombie plays walk animation")
		zombie.attack_animation_timer = zombie.attack_animation_duration
		zombie._update_animation()
		_check(zombie.character_sprite.animation == &"attack", "Zombie attack timer plays attack animation")
		zombie.take_damage(1)
		zombie._update_animation()
		_check(zombie.character_sprite.animation == &"hurt", "Zombie damage plays hurt animation")
		zombie.take_damage(zombie.health)
		_check(zombie.is_dead, "Lethal zombie damage starts faint state")
		_check(zombie.character_sprite.animation == &"faint", "Lethal zombie damage plays faint animation")
		await physics_frame
		_check(is_instance_valid(zombie), "Zombie remains briefly for faint presentation")
		zombie.queue_free()

	host.queue_free()
	_finish()

func _check_single_frame_animation(frames: SpriteFrames, animation_name: StringName, check_feet_baseline: bool = true) -> void:
	_check(frames.has_animation(animation_name), "%s animation exists" % animation_name)
	if not frames.has_animation(animation_name):
		return
	_check(frames.get_frame_count(animation_name) == 1, "%s animation has one frame" % animation_name)
	var texture := frames.get_frame_texture(animation_name, 0)
	_check(texture != null, "%s texture loads" % animation_name)
	if texture == null:
		return
	_check(texture.get_size() == Vector2(256.0, 256.0), "%s texture is 256x256" % animation_name)
	if check_feet_baseline:
		_check(texture.get_image().get_used_rect().end.y == 230, "%s art uses the standard feet baseline" % animation_name)

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)

func _finish() -> void:
	if failures.is_empty():
		print("Production animation checks passed.")
		quit(0)
	else:
		printerr("Production animation checks failed: ", ", ".join(failures))
		quit(1)
