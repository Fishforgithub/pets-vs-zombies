extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var crow_scene := load("res://game/enemies/stage2/zombie_crow.tscn") as PackedScene
	var player_scene := load("res://game/player/player.tscn") as PackedScene
	_check(crow_scene != null, "Zombie crow scene loads")
	_check(player_scene != null, "Player scene loads for crow targeting")
	if crow_scene == null or player_scene == null:
		_finish()
		return

	var host := Node2D.new()
	root.add_child(host)
	current_scene = host
	var player := player_scene.instantiate() as PlayerGirl
	player.position = Vector2(100.0, 150.0)
	host.add_child(player)
	var crow := crow_scene.instantiate() as ZombieCrow
	crow.position = Vector2.ZERO
	host.add_child(crow)
	await process_frame

	_check(crow.is_in_group("enemies"), "Crow joins the enemy target group")
	_check(crow.health == crow.max_health, "Crow starts at maximum health")
	_check(crow.experience_reward > 0 and crow.currency_reward > 0, "Crow exposes progression rewards")
	var frames := crow.character_sprite.sprite_frames
	_check(frames.has_animation(&"fly"), "Crow fly animation exists")
	_check(frames.get_frame_count(&"fly") == 6, "Crow fly animation has six frames")
	_check(is_equal_approx(frames.get_animation_speed(&"fly"), 10.0), "Crow fly animation uses manifest playback speed")
	for frame_index in range(frames.get_frame_count(&"fly")):
		var texture := frames.get_frame_texture(&"fly", frame_index)
		_check(texture != null and texture.get_size() == Vector2(256.0, 256.0), "Crow fly frame %d is a 256x256 atlas cell" % frame_index)
	for animation_name in [&"dive", &"hurt", &"defeated"]:
		_check(frames.has_animation(animation_name), "Crow %s animation exists" % animation_name)
		_check(frames.get_frame_count(animation_name) == 1, "Crow %s animation has one authored pose" % animation_name)

	crow.target = player
	player.position.x = -100.0
	crow._update_facing()
	_check(not crow.character_sprite.flip_h, "Left-authored crow displays as-is toward a player on the left")
	player.position.x = 100.0
	crow._update_facing()
	_check(crow.character_sprite.flip_h, "Left-authored crow mirrors toward a player on the right")

	crow.attack_cooldown = 0.0
	crow._update_state(0.01)
	_check(crow.state == ZombieCrow.State.TELEGRAPH, "Crow enters a telegraph before diving")
	_check(not crow.dive_hit_consumed, "Telegraph arms one dive damage window")
	crow.state_timer = 0.0
	crow._update_state(0.01)
	_check(crow.state == ZombieCrow.State.DIVE, "Telegraph transitions into a dive")
	_check(crow.dive_direction.y > 0.0, "Crow dive aims down toward the player")
	crow._update_animation()
	_check(crow.character_sprite.animation == &"dive", "Dive state uses the authored dive pose")

	crow.take_damage(1, Vector2.LEFT)
	_check(crow.health == crow.max_health - 1, "Crow takes projectile damage")
	_check(crow.state == ZombieCrow.State.RECOVER, "Damage cancels an active dive")
	_check(crow.dive_hit_consumed, "Damage closes the dive damage window")
	_check(crow.character_sprite.animation == &"hurt", "Damage uses the authored hurt pose")

	var defeated_events: Array[WaveEnemy] = []
	crow.defeated.connect(func(enemy: WaveEnemy) -> void: defeated_events.append(enemy))
	crow.take_damage(crow.health)
	_check(crow.is_dead, "Lethal damage defeats the crow")
	_check(not crow.is_in_group("enemies"), "Defeated crow leaves the enemy target group")
	_check(crow.collision_layer == 0 and crow.collision_mask == 0, "Defeated crow disables combat collision")
	_check(crow.character_sprite.animation == &"defeated", "Defeated crow holds the authored defeated pose")
	_check(defeated_events.size() == 1 and defeated_events[0] == crow, "Crow emits one typed defeated signal")

	host.queue_free()
	_finish()

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)

func _finish() -> void:
	if failures.is_empty():
		print("Zombie crow checks passed.")
		quit(0)
	else:
		printerr("Zombie crow checks failed: ", ", ".join(failures))
		quit(1)
