extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var doctor_scene := load("res://game/enemies/stage2/zombie_doctor.tscn") as PackedScene
	var player_scene := load("res://game/player/player.tscn") as PackedScene
	_check(doctor_scene != null, "Zombie doctor scene loads")
	_check(player_scene != null, "Player scene loads for doctor targeting")
	if doctor_scene == null or player_scene == null:
		_finish()
		return

	var host := Node2D.new()
	root.add_child(host)
	current_scene = host
	var player := player_scene.instantiate() as PlayerGirl
	player.position = Vector2(180.0, 0.0)
	host.add_child(player)
	var doctor := doctor_scene.instantiate() as ZombieDoctor
	doctor.position = Vector2.ZERO
	host.add_child(doctor)
	await process_frame

	_check(doctor is WaveEnemy, "Doctor implements the shared wave enemy interface")
	_check(doctor.health == doctor.max_health, "Doctor starts at maximum health")
	_check(doctor.experience_reward > 0 and doctor.currency_reward > 0, "Doctor exposes progression rewards")
	_check(doctor.zap_area != null and doctor.zap_collision_shape != null, "Doctor has a separate forward zap area")
	_check(doctor.zap_collision_shape.disabled, "Zap area starts disabled")
	var frames := doctor.character_sprite.sprite_frames
	_check(frames.has_animation(&"walk") and frames.get_frame_count(&"walk") == 6, "Doctor walk animation has six frames")
	_check(is_equal_approx(frames.get_animation_speed(&"walk"), 8.0), "Doctor walk uses manifest playback speed")
	for animation_name in [&"zap", &"hurt", &"defeated"]:
		_check(frames.has_animation(animation_name), "Doctor %s animation exists" % animation_name)
		_check(frames.get_frame_count(animation_name) == 1, "Doctor %s uses one authored pose" % animation_name)

	doctor.target = player
	player.position.x = -180.0
	doctor._update_facing()
	_check(not doctor.character_sprite.flip_h, "Left-authored doctor displays as-is toward a player on the left")
	_check(doctor.zap_area.position.x < 0.0, "Left-facing zap area stays in front of the doctor")
	player.position.x = 180.0
	doctor._update_facing()
	_check(doctor.character_sprite.flip_h, "Left-authored doctor mirrors toward a player on the right")
	_check(doctor.zap_area.position.x > 0.0, "Right-facing zap area mirrors with the doctor")

	doctor.zap_cooldown_timer = 0.0
	doctor._update_movement_and_attack()
	_check(doctor.zap_timer > 0.0, "Doctor starts a zap inside preferred range")
	doctor._update_animation()
	_check(doctor.character_sprite.animation == &"zap", "Zap action uses the authored zap pose")
	var health_before := player.health
	doctor.zap_timer = doctor.zap_duration * 0.5
	doctor._process_zap(0.01)
	_check(doctor.zap_event_consumed, "Zap discharge event is consumed once")
	_check(player.health == health_before - doctor.zap_damage, "Zap damages a player in the forward area")
	_check(player.movement_slow_timer > 0.0, "Zap applies a timed movement control effect")
	_check(is_equal_approx(player.movement_speed_multiplier, doctor.zap_speed_multiplier), "Zap applies its configured speed multiplier")
	_check(_find_effect(host, 0) != null, "Zap spawns the authored electric-hit effect")
	doctor._process_zap(0.01)
	_check(player.health == health_before - doctor.zap_damage, "One zap cannot damage the player twice")
	player._update_action_timers(doctor.zap_slow_duration)
	_check(is_equal_approx(player.movement_speed_multiplier, 1.0), "Player speed returns to normal after zap control expires")

	doctor._begin_zap()
	doctor.take_damage(1, Vector2.LEFT)
	_check(is_equal_approx(doctor.zap_timer, 0.0), "Damage cancels an active zap")
	_check(doctor.zap_collision_shape.disabled, "Damage closes the zap hitbox")
	_check(doctor.character_sprite.animation == &"hurt", "Damage uses the authored hurt pose")
	var defeated_events: Array[WaveEnemy] = []
	doctor.defeated.connect(func(enemy: WaveEnemy) -> void: defeated_events.append(enemy))
	doctor.take_damage(doctor.health)
	_check(doctor.is_dead, "Lethal damage defeats the doctor")
	_check(not doctor.is_in_group("enemies"), "Defeated doctor leaves the enemy target group")
	_check(doctor.collision_layer == 0 and doctor.collision_mask == 0, "Defeated doctor disables combat collision")
	_check(doctor.character_sprite.animation == &"defeated", "Defeated doctor holds the authored defeated pose")
	_check(defeated_events.size() == 1 and defeated_events[0] == doctor, "Doctor emits one shared defeated signal")

	host.queue_free()
	_finish()

func _find_effect(host: Node, effect_index: int) -> Stage2HospitalEffect:
	for child in host.get_children():
		if child is Stage2HospitalEffect and (child as Stage2HospitalEffect).effect_index == effect_index:
			return child as Stage2HospitalEffect
	return null

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)

func _finish() -> void:
	if failures.is_empty():
		print("Zombie doctor checks passed.")
		quit(0)
	else:
		printerr("Zombie doctor checks failed: ", ", ".join(failures))
		quit(1)
