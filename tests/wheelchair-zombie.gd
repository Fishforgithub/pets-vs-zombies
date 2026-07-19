extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var wheelchair_scene := load("res://game/enemies/stage2/wheelchair_zombie.tscn") as PackedScene
	var player_scene := load("res://game/player/player.tscn") as PackedScene
	_check(wheelchair_scene != null, "Wheelchair zombie scene loads")
	_check(player_scene != null, "Player scene loads for wheelchair targeting")
	if wheelchair_scene == null or player_scene == null:
		_finish()
		return

	var host := Node2D.new()
	root.add_child(host)
	current_scene = host
	var player := player_scene.instantiate() as PlayerGirl
	host.add_child(player)
	var wheelchair := wheelchair_scene.instantiate() as WheelchairZombie
	host.add_child(wheelchair)
	await process_frame

	_check(wheelchair is WaveEnemy, "Wheelchair zombie implements the shared wave enemy interface")
	_check(wheelchair.health == wheelchair.max_health, "Wheelchair zombie starts at maximum health")
	_check(wheelchair.body_collision_shape != null, "Wheelchair zombie has a separate body collision")
	_check(wheelchair.shield_area != null and wheelchair.shield_collision_shape != null, "Wheelchair zombie has a separate forward shield area")
	var frames := wheelchair.character_sprite.sprite_frames
	_check(frames.has_animation(&"roll") and frames.get_frame_count(&"roll") == 6, "Wheelchair roll animation has six frames")
	_check(is_equal_approx(frames.get_animation_speed(&"roll"), 10.0), "Wheelchair roll uses manifest playback speed")
	for animation_name in [&"charge", &"hurt", &"stunned", &"defeated"]:
		_check(frames.has_animation(animation_name), "Wheelchair %s animation exists" % animation_name)
		_check(frames.get_frame_count(animation_name) == 1, "Wheelchair %s uses one authored pose" % animation_name)

	wheelchair.target = player
	player.position.x = -180.0
	wheelchair._update_facing(-180.0)
	_check(not wheelchair.character_sprite.flip_h, "Left-authored wheelchair displays as-is toward a player on the left")
	_check(wheelchair.shield_area.position.x < 0.0, "Left-facing shield stays in front of the wheelchair")
	player.position.x = 180.0
	wheelchair._update_facing(180.0)
	_check(wheelchair.character_sprite.flip_h, "Left-authored wheelchair mirrors toward a player on the right")
	_check(wheelchair.shield_area.position.x > 0.0, "Right-facing shield mirrors with the wheelchair")

	var shield_events: Array[Vector2i] = []
	wheelchair.shield_blocked.connect(func(original: int, applied: int) -> void: shield_events.append(Vector2i(original, applied)))
	var health_before := wheelchair.health
	wheelchair.take_damage(20, Vector2.LEFT)
	var expected_blocked_damage := maxi(1, ceili(20.0 * (1.0 - wheelchair.shield_damage_reduction)))
	_check(wheelchair.health == health_before - expected_blocked_damage, "Front shield reduces incoming projectile damage")
	_check(shield_events == [Vector2i(20, expected_blocked_damage)], "Shield reports original and reduced damage")
	health_before = wheelchair.health
	wheelchair.take_damage(20, Vector2.RIGHT)
	_check(wheelchair.health == health_before - 20, "Rear hit deals full damage")

	wheelchair.hurt_timer = 0.0
	wheelchair._begin_windup()
	_check(wheelchair.state == WheelchairZombie.State.WINDUP, "Wheelchair telegraphs before charging")
	wheelchair._process_windup(wheelchair.charge_windup_duration)
	_check(wheelchair.state == WheelchairZombie.State.CHARGE, "Wheelchair windup transitions into charge")
	_check(wheelchair.charge_direction > 0.0, "Right-facing wheelchair charges right")
	wheelchair.take_damage(20, Vector2.RIGHT)
	_check(wheelchair.state == WheelchairZombie.State.STUNNED, "Rear hit during charge opens the stunned window")
	_check(not wheelchair.shield_enabled, "Stunned wheelchair disables its shield")
	wheelchair._update_animation()
	_check(wheelchair.character_sprite.animation == &"stunned", "Stunned state uses the authored stunned pose")
	_check(_find_effect(host, 2) != null, "Charge interruption spawns the authored skid-dust effect")

	health_before = wheelchair.health
	wheelchair.take_damage(10, Vector2.LEFT)
	_check(wheelchair.health == health_before - 10, "Stunned wheelchair takes full frontal damage")
	wheelchair._process_stunned(wheelchair.stun_duration)
	_check(wheelchair.state == WheelchairZombie.State.ROLL, "Wheelchair returns to rolling after stun")
	_check(wheelchair.shield_enabled, "Wheelchair restores its shield after stun")

	var defeated_events: Array[WaveEnemy] = []
	wheelchair.defeated.connect(func(enemy: WaveEnemy) -> void: defeated_events.append(enemy))
	wheelchair.take_damage(wheelchair.health, Vector2.ZERO)
	_check(wheelchair.is_dead, "Lethal damage defeats the wheelchair zombie")
	_check(not wheelchair.is_in_group("enemies"), "Defeated wheelchair leaves the enemy target group")
	_check(wheelchair.collision_layer == 0 and wheelchair.collision_mask == 0, "Defeated wheelchair disables body collision")
	_check(not wheelchair.shield_enabled, "Defeated wheelchair permanently disables its shield")
	_check(wheelchair.character_sprite.animation == &"defeated", "Defeated wheelchair holds the authored defeated pose")
	_check(defeated_events.size() == 1 and defeated_events[0] == wheelchair, "Wheelchair emits one shared defeated signal")

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
		print("Wheelchair zombie checks passed.")
		quit(0)
	else:
		printerr("Wheelchair zombie checks failed: ", ", ".join(failures))
		quit(1)
