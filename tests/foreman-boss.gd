extends SceneTree

var failures: Array[String] = []
var boss_defeated: bool = false

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed_scene := load("res://game/bosses/foreman_boss.tscn") as PackedScene
	_check(packed_scene != null, "Foreman boss scene loads")
	if packed_scene == null:
		_finish()
		return

	var host := Node2D.new()
	root.add_child(host)
	current_scene = host
	var floor := StaticBody2D.new()
	var floor_collision := CollisionShape2D.new()
	var floor_shape := RectangleShape2D.new()
	floor_shape.size = Vector2(600.0, 20.0)
	floor_collision.shape = floor_shape
	floor.add_child(floor_collision)
	floor.position = Vector2(0.0, 10.0)
	host.add_child(floor)

	var player_scene := load("res://game/player/player.tscn") as PackedScene
	var player := player_scene.instantiate() as PlayerGirl
	host.add_child(player)
	var boss := packed_scene.instantiate() as ForemanBoss
	boss.position = Vector2(100.0, 0.0)
	boss.defeat_delay = 0.0
	host.add_child(boss)
	boss.target = player
	boss.defeated.connect(_on_boss_defeated)
	await physics_frame
	await physics_frame

	_check(boss.body_collision != null, "Boss has a separate body collision")
	_check(boss.vulnerable_collision != null, "Boss has a separate vulnerable area")
	_check(boss.sweep_collision != null, "Boss has a separate hammer sweep hitbox")
	_check(boss.slam_collision != null, "Boss has a separate slam impact hitbox")
	_check(boss.is_in_group("enemies"), "Boss is targetable by player and pet attacks")

	var frames := boss.character_sprite.sprite_frames
	for animation_name in [&"idle", &"hurt", &"rage", &"stunned", &"defeated"]:
		_check(frames.has_animation(animation_name), "%s boss animation exists" % animation_name)
		if frames.has_animation(animation_name):
			_check(frames.get_frame_count(animation_name) == 1, "%s is a state pose" % animation_name)
	for animation_name in [&"walk", &"sweep", &"slam"]:
		_check(frames.has_animation(animation_name), "%s boss animation exists" % animation_name)
		if frames.has_animation(animation_name):
			_check(frames.get_frame_count(animation_name) == 4, "%s has four frames" % animation_name)
			for frame_index in range(4):
				var texture := frames.get_frame_texture(animation_name, frame_index)
				_check(texture != null and texture.get_size() == Vector2(512.0, 512.0), "%s frame %d is 512x512" % [animation_name, frame_index])

	boss._update_facing(-10.0)
	_check(not boss.character_sprite.flip_h and boss.sweep_area.position.x < 0.0 and boss.slam_area.position.x < 0.0, "Authored left-facing boss and hitboxes stay aligned")
	boss._update_facing(10.0)
	_check(boss.character_sprite.flip_h and boss.sweep_area.position.x > 0.0 and boss.slam_area.position.x > 0.0, "Mirrored boss and hitboxes face right together")

	var bullet_scene := load("res://game/projectiles/bullet.tscn") as PackedScene
	var bullet := bullet_scene.instantiate() as GameBullet
	host.add_child(bullet)
	var health_before_bullet := boss.health
	bullet.configure(Vector2.RIGHT, &"enemies", 25, Color.WHITE)
	bullet._try_damage(boss.vulnerable_area)
	_check(boss.health == health_before_bullet - 25, "Projectile routes vulnerable-area damage to the boss")

	boss.state = ForemanBoss.State.SWEEP
	boss.character_sprite.play(&"sweep")
	boss.character_sprite.pause()
	boss.character_sprite.frame = 1
	boss._on_animation_frame_changed()
	await physics_frame
	_check(boss.sweep_collision.disabled, "Sweep hitbox is disabled before active frame 2")
	boss._update_facing(-10.0)
	boss.character_sprite.frame = 2
	boss._on_animation_frame_changed()
	await physics_frame
	await physics_frame
	_check(not boss.sweep_collision.disabled, "Sweep hitbox enables on frame 2")
	_check(player.health == player.max_health - boss.sweep_damage, "Active sweep frame damages the player once")
	boss.character_sprite.frame = 3
	boss._on_animation_frame_changed()
	await physics_frame
	_check(boss.sweep_collision.disabled, "Sweep hitbox disables during recovery")

	player.global_position = boss.global_position + Vector2(58.0, 0.0)
	boss._update_facing(58.0)
	boss._start_slam()
	boss.character_sprite.pause()
	boss.character_sprite.frame = 1
	boss._on_animation_frame_changed()
	await physics_frame
	_check(boss.slam_collision.disabled, "Slam impact hitbox is disabled before active frame 2")
	var health_before_slam := player.health
	boss.character_sprite.frame = 2
	boss._on_animation_frame_changed()
	await physics_frame
	await physics_frame
	_check(not boss.slam_collision.disabled, "Slam impact hitbox enables on frame 2")
	_check(player.health == health_before_slam - boss.slam_damage, "Active slam frame damages a nearby player once")
	var shockwaves := _find_shockwaves(host)
	_check(shockwaves.size() == 2, "Slam impact creates one left and one right shockwave")
	if shockwaves.size() == 2:
		var directions := [float(shockwaves[0].get("travel_direction")), float(shockwaves[1].get("travel_direction"))]
		directions.sort()
		_check(directions == [-1.0, 1.0], "Slam shockwaves travel in opposite directions")
		for shockwave in shockwaves:
			shockwave.set("speed", 0.0)
			(shockwave.get_node("EffectSprite") as AnimatedSprite2D).pause()
		var test_wave := shockwaves[0]
		shockwaves[1].global_position = Vector2(1000.0, 0.0)
		test_wave.global_position = player.global_position
		var wave_sprite := test_wave.get_node("EffectSprite") as AnimatedSprite2D
		var wave_collision := test_wave.get_node("DamageCollision") as CollisionShape2D
		wave_sprite.pause()
		wave_sprite.frame = 1
		test_wave.call("_on_animation_frame_changed")
		await physics_frame
		_check(wave_collision.disabled, "Shockwave damage is disabled before active frame 2")
		var health_before_wave := player.health
		wave_sprite.frame = 2
		test_wave.call("_on_animation_frame_changed")
		await physics_frame
		await physics_frame
		test_wave.call("_damage_overlapping_targets")
		_check(not wave_collision.disabled, "Shockwave damage enables on frame 2")
		_check(player.health == health_before_wave - boss.shockwave_damage, "Active shockwave frame damages the player once")
		test_wave.call("_on_animation_frame_changed")
		await physics_frame
		_check(player.health == health_before_wave - boss.shockwave_damage, "Shockwave cannot damage the same player twice")
	boss._on_animation_frame_changed()
	await physics_frame
	_check(_find_shockwaves(host).size() == 2, "Slam impact cannot emit duplicate shockwaves on the same frame")
	boss.character_sprite.frame = 3
	boss._on_animation_frame_changed()
	await physics_frame
	_check(boss.slam_collision.disabled, "Slam impact hitbox disables during recovery")

	boss.take_damage(boss.health)
	await physics_frame
	_check(boss.state == ForemanBoss.State.DEFEATED, "Lethal damage enters defeated state")
	_check(not boss.is_in_group("enemies"), "Defeated boss is removed from target group")
	_check(boss.body_collision.disabled and boss.vulnerable_collision.disabled, "Defeated boss disables collision and damage reception")
	_check(boss_defeated, "Boss emits defeated after presentation delay")

	host.queue_free()
	_finish()

func _on_boss_defeated(_boss: ForemanBoss) -> void:
	boss_defeated = true

func _find_shockwaves(host: Node) -> Array[Area2D]:
	var shockwaves: Array[Area2D] = []
	for child in host.get_children():
		if child is Area2D and child.scene_file_path == "res://game/bosses/foreman_shockwave.tscn":
			shockwaves.append(child as Area2D)
	return shockwaves

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)

func _finish() -> void:
	if failures.is_empty():
		print("Foreman boss checks passed.")
		quit(0)
	else:
		printerr("Foreman boss checks failed: ", ", ".join(failures))
		quit(1)
