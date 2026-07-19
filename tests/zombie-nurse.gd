extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var nurse_scene := load("res://game/enemies/stage2/zombie_nurse.tscn") as PackedScene
	var player_scene := load("res://game/player/player.tscn") as PackedScene
	var zombie_scene := load("res://game/enemies/zombie.tscn") as PackedScene
	_check(nurse_scene != null, "Zombie nurse scene loads")
	_check(player_scene != null and zombie_scene != null, "Nurse test dependencies load")
	if nurse_scene == null or player_scene == null or zombie_scene == null:
		_finish()
		return

	var host := Node2D.new()
	root.add_child(host)
	current_scene = host
	var player := player_scene.instantiate() as PlayerGirl
	player.position = Vector2(180.0, 0.0)
	host.add_child(player)
	var nurse := nurse_scene.instantiate() as ZombieNurse
	nurse.position = Vector2.ZERO
	host.add_child(nurse)
	await process_frame

	_check(nurse is WaveEnemy, "Nurse implements the shared wave enemy interface")
	_check(nurse.health == nurse.max_health, "Nurse starts at maximum health")
	_check(nurse.experience_reward > 0 and nurse.currency_reward > 0, "Nurse exposes progression rewards")
	var frames := nurse.character_sprite.sprite_frames
	_check(frames.has_animation(&"walk") and frames.get_frame_count(&"walk") == 6, "Nurse walk animation has six frames")
	_check(is_equal_approx(frames.get_animation_speed(&"walk"), 8.0), "Nurse walk uses manifest playback speed")
	for animation_name in [&"throw", &"buff", &"hurt", &"defeated"]:
		_check(frames.has_animation(animation_name), "Nurse %s animation exists" % animation_name)
		_check(frames.get_frame_count(animation_name) == 1, "Nurse %s uses one authored pose" % animation_name)

	nurse.target = player
	player.position.x = -180.0
	nurse._update_facing()
	_check(not nurse.character_sprite.flip_h, "Left-authored nurse displays as-is toward a player on the left")
	player.position.x = 180.0
	nurse._update_facing()
	_check(nurse.character_sprite.flip_h, "Left-authored nurse mirrors toward a player on the right")

	nurse.support_cooldown = 1.0
	nurse.attack_cooldown = 0.0
	nurse._update_movement_and_actions()
	_check(nurse.active_action == ZombieNurse.Action.THROW, "Nurse starts a ranged throw inside preferred range")
	nurse._update_animation()
	_check(nurse.character_sprite.animation == &"throw", "Throw action uses the authored throw pose")
	nurse.action_timer = nurse.throw_duration * 0.5
	nurse._process_action(0.01)
	var projectile := _find_bandage(host)
	_check(projectile != null, "Throw releases a separate bandage projectile")
	_check(nurse.action_event_consumed, "Throw release event is consumed once")
	if projectile != null:
		var health_before := player.health
		projectile._on_body_entered(player)
		_check(player.health == health_before - nurse.bandage_damage, "Bandage projectile damages the player")

	nurse.active_action = ZombieNurse.Action.NONE
	nurse.action_event_consumed = false
	var ally := zombie_scene.instantiate() as ZombieEnemy
	ally.position = Vector2(40.0, 0.0)
	host.add_child(ally)
	await process_frame
	var buff_events: Array[Dictionary] = []
	nurse.support_buff_requested.connect(
		func(source: ZombieNurse, radius: float, duration: float, multiplier: float) -> void:
			buff_events.append({"source": source, "radius": radius, "duration": duration, "multiplier": multiplier})
	)
	nurse.support_cooldown = 0.0
	nurse.attack_cooldown = 0.0
	nurse._update_movement_and_actions()
	_check(nurse.active_action == ZombieNurse.Action.BUFF, "Nurse prioritizes support when an ally is nearby")
	nurse._update_animation()
	_check(nurse.character_sprite.animation == &"buff", "Support action uses the authored buff pose")
	nurse.action_timer = nurse.throw_duration * 0.5
	nurse._process_action(0.01)
	nurse._process_action(0.01)
	_check(buff_events.size() == 1, "Support action emits one buff event")
	_check(ally.support_buff_timer > 0.0, "Support action applies a timed buff to a nearby ally")
	_check(is_equal_approx(ally.get_support_speed_multiplier(), nurse.buff_speed_multiplier), "Support action increases nearby ally movement speed")
	if buff_events.size() == 1:
		_check(buff_events[0].source == nurse, "Buff event identifies its nurse source")
		_check(is_equal_approx(buff_events[0].radius, nurse.buff_radius), "Buff event exposes its gameplay radius")
		_check(buff_events[0].multiplier > 1.0, "Buff event exposes a positive speed multiplier")
	ally.update_support_buff(nurse.buff_duration)
	_check(is_equal_approx(ally.get_support_speed_multiplier(), 1.0), "Support speed returns to normal when the buff expires")

	nurse.take_damage(1, Vector2.LEFT)
	_check(nurse.active_action == ZombieNurse.Action.NONE, "Damage cancels nurse actions")
	_check(nurse.character_sprite.animation == &"hurt", "Damage uses the authored hurt pose")
	var defeated_events: Array[WaveEnemy] = []
	nurse.defeated.connect(func(enemy: WaveEnemy) -> void: defeated_events.append(enemy))
	nurse.take_damage(nurse.health)
	_check(nurse.is_dead, "Lethal damage defeats the nurse")
	_check(not nurse.is_in_group("enemies"), "Defeated nurse leaves the enemy target group")
	_check(nurse.collision_layer == 0 and nurse.collision_mask == 0, "Defeated nurse disables combat collision")
	_check(nurse.character_sprite.animation == &"defeated", "Defeated nurse holds the authored defeated pose")
	_check(defeated_events.size() == 1 and defeated_events[0] == nurse, "Nurse emits one shared defeated signal")

	host.queue_free()
	_finish()

func _find_bandage(host: Node) -> BandageProjectile:
	for child in host.get_children():
		if child is BandageProjectile:
			return child as BandageProjectile
	return null

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)

func _finish() -> void:
	if failures.is_empty():
		print("Zombie nurse checks passed.")
		quit(0)
	else:
		printerr("Zombie nurse checks failed: ", ", ".join(failures))
		quit(1)
