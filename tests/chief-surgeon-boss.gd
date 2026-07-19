extends SceneTree

var failures: Array[String] = []
var defeated_seen: bool = false

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed_scene := load("res://game/bosses/chief_surgeon_boss.tscn") as PackedScene
	_check(packed_scene != null, "Chief Surgeon boss scene loads")
	if packed_scene == null:
		_finish()
		return
	var host := Node2D.new()
	root.add_child(host)
	current_scene = host
	var floor := StaticBody2D.new()
	var floor_collision := CollisionShape2D.new()
	var floor_shape := RectangleShape2D.new()
	floor_shape.size = Vector2(900.0, 30.0)
	floor_collision.shape = floor_shape
	floor_collision.position = Vector2(0.0, 15.0)
	floor.add_child(floor_collision)
	host.add_child(floor)
	var player := (load("res://game/player/player.tscn") as PackedScene).instantiate() as PlayerGirl
	player.position = Vector2(-240.0, 0.0)
	host.add_child(player)
	var boss := packed_scene.instantiate() as ChiefSurgeonBoss
	boss.position = Vector2(120.0, 0.0)
	boss.defeat_delay = 0.0
	host.add_child(boss)
	boss.target = player
	boss.defeated.connect(_on_defeated)
	await physics_frame
	await physics_frame

	_check(boss.is_in_group("enemies"), "Chief Surgeon is targetable as a boss enemy")
	_check(boss.max_health == 900 and boss.experience_reward == 260, "Chief Surgeon uses Stage 2 boss tuning")
	for animation_name in [&"idle", &"walk", &"sweep", &"slam", &"hurt", &"rage", &"stunned", &"defeated"]:
		_check(boss.character_sprite.sprite_frames.has_animation(animation_name), "%s animation exists" % animation_name)
	for animation_name in [&"walk", &"sweep", &"slam"]:
		_check(boss.character_sprite.sprite_frames.get_frame_count(animation_name) == 4, "%s uses four authored frames" % animation_name)

	var original_speed := boss.move_speed
	var original_interval := boss.attack_interval
	boss.take_damage(boss.max_health / 2)
	_check(boss.phase_two, "Half health activates Chief Surgeon phase two")
	_check(boss.move_speed > original_speed and boss.attack_interval < original_interval, "Phase two increases movement and attack pressure")

	boss.state = ForemanBoss.State.SLAM
	boss.character_sprite.play(&"slam")
	boss.character_sprite.pause()
	boss.character_sprite.frame = 2
	boss._on_animation_frame_changed()
	await process_frame
	await process_frame
	var equipment_hazards: Array[SurgeonEquipmentHazard] = []
	var impact_effect: Stage2HospitalEffect
	for child in host.get_children():
		if child is SurgeonEquipmentHazard:
			equipment_hazards.append(child as SurgeonEquipmentHazard)
		elif child is Stage2HospitalEffect and (child as Stage2HospitalEffect).effect_index == 3:
			impact_effect = child as Stage2HospitalEffect
	_check(equipment_hazards.size() == 2, "Chief Surgeon slam launches two rolling equipment hazards")
	_check(impact_effect != null, "Chief Surgeon slam spawns the hospital lamp-impact effect")
	if equipment_hazards.size() == 2:
		var directions := [equipment_hazards[0].travel_direction, equipment_hazards[1].travel_direction]
		directions.sort()
		_check(directions == [-1.0, 1.0], "Equipment hazards travel in opposite directions")
		var health_before := player.health
		equipment_hazards[0]._on_body_entered(player)
		_check(player.health == health_before - boss.shockwave_damage, "Rolling equipment damages the player once")

	boss.take_damage(boss.health)
	await process_frame
	_check(boss.state == ForemanBoss.State.DEFEATED, "Lethal damage defeats Chief Surgeon")
	_check(defeated_seen, "Chief Surgeon emits its stage-completion signal")
	host.queue_free()
	_finish()

func _on_defeated(_boss: ForemanBoss) -> void:
	defeated_seen = true

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)

func _finish() -> void:
	if failures.is_empty():
		print("Chief Surgeon checks passed.")
		quit(0)
	else:
		printerr("Chief Surgeon checks failed: ", ", ".join(failures))
		quit(1)
