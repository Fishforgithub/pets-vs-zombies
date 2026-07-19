extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed_scene := load("res://game/stages/stage2.tscn") as PackedScene
	_check(packed_scene != null, "Stage 2 gameplay scene loads")
	if packed_scene == null:
		_finish()
		return
	var stage := packed_scene.instantiate() as StageTwo
	stage.persistence_enabled = false
	stage.use_stage_two_default_waves = false
	stage.get_node("WaveDirector").wave_configs = _fast_waves()
	stage.get_node("WaveDirector").inter_wave_delay = 0.0
	root.add_child(stage)
	current_scene = stage
	await _wait_frames(3)

	_check(stage.production_background_active, "Stage 2 uses the hospital production background")
	_check(stage.ground_tiles_texture != null, "Stage 2 uses hospital ground tiles")
	_check(stage.get_node("Hazards").get_child_count() == 2, "Stage 2 places two electric puddle hazards")
	_check(stage.wave_director.get_total_wave_count() == 5, "Stage 2 defines five gameplay waves")

	var seen_types: Dictionary = {}
	for _iteration in range(240):
		for enemy_node in stage.enemies.get_children():
			if enemy_node is WaveEnemy:
				if enemy_node is ZombieCrow:
					seen_types[&"crow"] = true
				elif enemy_node is ZombieNurse:
					seen_types[&"nurse"] = true
				elif enemy_node is ZombieDoctor:
					seen_types[&"doctor"] = true
				elif enemy_node is WheelchairZombie:
					seen_types[&"wheelchair"] = true
				enemy_node.call("take_damage", 9999)
		await process_frame
		await process_frame
		if stage.wave_director.finished:
			break
	_check(stage.wave_director.finished, "Defeating five mixed waves completes Stage 2 wave progression")
	_check(stage.defeated_count == 5, "Fast Stage 2 smoke waves report all five defeats")
	_check(is_instance_valid(stage.active_boss) and stage.active_boss is ChiefSurgeonBoss, "Chief Surgeon enters after Stage 2 wave five")
	_check(seen_types.size() >= 4, "Stage 2 wave sequence exercises all four implemented enemy roles")
	if is_instance_valid(stage.active_boss):
		stage.active_boss.defeat_delay = 0.0
		stage.active_boss.take_damage(stage.active_boss.health)
		await process_frame
		await physics_frame
	_check(stage.finished, "Defeating Chief Surgeon completes Stage 2")
	_check(stage.player.progression.is_stage_completed(2) and stage.player.progression.is_stage_unlocked(3), "Stage 2 completion persists and unlocks the next route position")
	_check(stage.stage_result.visible and "STAGE 2 CLEAR" in stage.stage_result.title_label.text, "Stage 2 completion shows its result screen")
	_check("STAGE 3" in stage.stage_result.stage_label.text and "COMING SOON" in stage.stage_result.status_label.text, "Stage 2 result points to the future route")
	stage.queue_free()
	_finish()

func _fast_waves() -> Array[Dictionary]:
	return [
		{"enemy_count": 1, "spawn_interval": 0.0, "max_alive": 1, "spawn_sides": [1], "enemy_types": [&"crow"]},
		{"enemy_count": 1, "spawn_interval": 0.0, "max_alive": 1, "spawn_sides": [-1], "enemy_types": [&"nurse"]},
		{"enemy_count": 1, "spawn_interval": 0.0, "max_alive": 1, "spawn_sides": [1], "enemy_types": [&"doctor"]},
		{"enemy_count": 1, "spawn_interval": 0.0, "max_alive": 1, "spawn_sides": [-1], "enemy_types": [&"wheelchair"]},
		{"enemy_count": 1, "spawn_interval": 0.0, "max_alive": 1, "spawn_sides": [1], "enemy_types": [&"crow"]},
	]

func _wait_frames(count: int) -> void:
	for _frame in range(count):
		await physics_frame

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)

func _finish() -> void:
	if failures.is_empty():
		print("Stage 2 gameplay smoke checks passed.")
		quit(0)
	else:
		printerr("Stage 2 gameplay smoke checks failed: ", ", ".join(failures))
		quit(1)
