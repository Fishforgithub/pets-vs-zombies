extends SceneTree

var failures: Array[String] = []
var director: WaveDirector
var enemies: Node2D
var spawned_sides: Array[int] = []
var started_waves: Array[int] = []
var completed_waves: Array[int] = []
var mixed_enemies: Array[WaveEnemy] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed_scene := load("res://game/stages/wave_director.tscn") as PackedScene
	_check(packed_scene != null, "Wave director scene loads")
	if packed_scene == null:
		_finish()
		return

	var host := Node.new()
	enemies = Node2D.new()
	enemies.name = "Enemies"
	host.add_child(enemies)
	director = packed_scene.instantiate() as WaveDirector
	host.add_child(director)
	root.add_child(host)
	current_scene = host

	_check(director.get_total_wave_count() == 5, "Stage 1 defines five waves")
	_check(director.get_total_enemy_count() == 26, "Default waves total 26 courier zombies")
	var expected_counts: Array[int] = [3, 4, 5, 6, 8]
	for index in range(expected_counts.size()):
		_check(director.get_wave_enemy_count(index) == expected_counts[index], "Wave %d enemy count is data-driven" % (index + 1))

	var test_configs: Array[Dictionary] = [
		{"enemy_count": 2, "spawn_interval": 0.0, "max_alive": 2, "spawn_sides": [1]},
		{"enemy_count": 3, "spawn_interval": 0.0, "max_alive": 3, "spawn_sides": [-1, 1]},
	]
	director.inter_wave_delay = 0.0
	director.wave_started.connect(_on_wave_started)
	director.wave_completed.connect(_on_wave_completed)
	director.configure(_spawn_enemy, test_configs)
	director.start()

	for _iteration in range(60):
		await process_frame
		for child in enemies.get_children():
			var enemy := child as ZombieEnemy
			if is_instance_valid(enemy) and not enemy.is_dead:
				enemy.take_damage(enemy.health)
		if director.finished:
			break

	_check(director.finished, "Director completes after every configured enemy is defeated")
	_check(started_waves == [1, 2], "Director starts waves in order")
	_check(completed_waves == [1, 2], "Director completes waves in order")
	_check(spawned_sides == [1, 1, -1, 1, -1], "Configured spawn directions repeat deterministically")

	var mixed_director := packed_scene.instantiate() as WaveDirector
	host.add_child(mixed_director)
	mixed_director.configure(_spawn_mixed_enemy, [{"enemy_count": 2, "spawn_interval": 0.0, "max_alive": 2}])
	mixed_director.start()
	for _iteration in range(10):
		await process_frame
		if mixed_enemies.size() == 2:
			break
	_check(mixed_enemies.size() == 2, "Director spawns a mixed wave through the shared enemy interface")
	if mixed_enemies.size() == 2:
		_check(mixed_enemies[0] is ZombieCrow, "Mixed wave accepts an aerial crow")
		_check(mixed_enemies[1] is ZombieNurse, "Mixed wave accepts a support nurse")
		(mixed_enemies[0] as ZombieCrow).take_damage((mixed_enemies[0] as ZombieCrow).health)
		(mixed_enemies[1] as ZombieNurse).take_damage((mixed_enemies[1] as ZombieNurse).health)
		await process_frame
	_check(mixed_director.finished, "Mixed enemy defeats complete the wave")

	host.queue_free()
	_finish()

func _spawn_enemy(spawn_side: int) -> ZombieEnemy:
	spawned_sides.append(spawn_side)
	var packed_enemy := load("res://game/enemies/zombie.tscn") as PackedScene
	var enemy := packed_enemy.instantiate() as ZombieEnemy
	enemies.add_child(enemy)
	return enemy

func _spawn_mixed_enemy(_spawn_side: int) -> WaveEnemy:
	var path := "res://game/enemies/stage2/zombie_crow.tscn" if mixed_enemies.is_empty() else "res://game/enemies/stage2/zombie_nurse.tscn"
	var packed_enemy := load(path) as PackedScene
	var enemy := packed_enemy.instantiate() as WaveEnemy
	enemies.add_child(enemy)
	mixed_enemies.append(enemy)
	return enemy

func _on_wave_started(wave_number: int, _total_waves: int, _enemy_count: int) -> void:
	started_waves.append(wave_number)

func _on_wave_completed(wave_number: int, _total_waves: int) -> void:
	completed_waves.append(wave_number)

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)

func _finish() -> void:
	if failures.is_empty():
		print("Wave director checks passed.")
		quit(0)
	else:
		printerr("Wave director checks failed: ", ", ".join(failures))
		quit(1)
