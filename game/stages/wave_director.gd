class_name WaveDirector
extends Node

signal wave_started(wave_number: int, total_waves: int, enemy_count: int)
signal wave_progress_changed(wave_number: int, total_waves: int, defeated: int, enemy_count: int)
signal wave_completed(wave_number: int, total_waves: int)
signal enemy_defeated(enemy: WaveEnemy)
signal all_waves_completed

const DEFAULT_WAVE_CONFIGS: Array[Dictionary] = [
	{"enemy_count": 3, "spawn_interval": 1.15, "max_alive": 2, "spawn_sides": [1]},
	{"enemy_count": 4, "spawn_interval": 0.9, "max_alive": 2, "spawn_sides": [1]},
	{"enemy_count": 5, "spawn_interval": 0.78, "max_alive": 3, "spawn_sides": [-1, 1]},
	{"enemy_count": 6, "spawn_interval": 0.62, "max_alive": 4, "spawn_sides": [-1, 1]},
	{"enemy_count": 8, "spawn_interval": 0.48, "max_alive": 5, "spawn_sides": [1, -1]},
]

@export var inter_wave_delay: float = 1.8

var wave_configs: Array[Dictionary] = DEFAULT_WAVE_CONFIGS.duplicate(true)
var current_wave_index: int = -1
var spawned_in_wave: int = 0
var defeated_in_wave: int = 0
var alive_in_wave: int = 0
var spawn_timer: float = 0.0
var intermission_remaining: float = 0.0
var running: bool = false
var wave_active: bool = false
var finished: bool = false
var spawn_factory: Callable

func configure(factory: Callable, configs: Array[Dictionary] = []) -> void:
	spawn_factory = factory
	if not configs.is_empty():
		wave_configs = configs.duplicate(true)

func start() -> void:
	if running or finished:
		return
	if not spawn_factory.is_valid():
		push_error("WaveDirector requires a valid spawn factory.")
		return
	if wave_configs.is_empty():
		push_error("WaveDirector requires at least one wave config.")
		return
	running = true
	current_wave_index = -1
	_begin_next_wave()

func _process(delta: float) -> void:
	if not running or finished:
		return
	if wave_active:
		_process_active_wave(delta)
		return
	intermission_remaining = maxf(0.0, intermission_remaining - delta)
	if intermission_remaining <= 0.0:
		_begin_next_wave()

func _process_active_wave(delta: float) -> void:
	var config := _current_config()
	var enemy_count := int(config.get("enemy_count", 0))
	var max_alive := maxi(1, int(config.get("max_alive", enemy_count)))
	if spawned_in_wave >= enemy_count or alive_in_wave >= max_alive:
		return
	spawn_timer = maxf(0.0, spawn_timer - delta)
	if spawn_timer > 0.0:
		return
	_spawn_one(config)
	spawn_timer = maxf(0.0, float(config.get("spawn_interval", 1.0)))

func _spawn_one(config: Dictionary) -> void:
	var sides: Array = config.get("spawn_sides", [1]) as Array
	if sides.is_empty():
		sides = [1]
	var spawn_side := int(sides[spawned_in_wave % sides.size()])
	var enemy := spawn_factory.call(spawn_side) as WaveEnemy
	if not is_instance_valid(enemy):
		push_error("WaveDirector spawn factory did not return a WaveEnemy.")
		running = false
		return
	spawned_in_wave += 1
	alive_in_wave += 1
	enemy.defeated.connect(_on_enemy_defeated)
	_emit_progress()

func _on_enemy_defeated(enemy: WaveEnemy) -> void:
	if not wave_active:
		return
	alive_in_wave = maxi(0, alive_in_wave - 1)
	defeated_in_wave += 1
	enemy_defeated.emit(enemy)
	_emit_progress()
	var enemy_count := get_wave_enemy_count(current_wave_index)
	if spawned_in_wave < enemy_count or defeated_in_wave < enemy_count:
		return
	wave_active = false
	wave_completed.emit(current_wave_index + 1, get_total_wave_count())
	if current_wave_index + 1 >= get_total_wave_count():
		finished = true
		running = false
		all_waves_completed.emit()
	else:
		intermission_remaining = inter_wave_delay

func _begin_next_wave() -> void:
	current_wave_index += 1
	if current_wave_index >= get_total_wave_count():
		finished = true
		running = false
		all_waves_completed.emit()
		return
	spawned_in_wave = 0
	defeated_in_wave = 0
	alive_in_wave = 0
	spawn_timer = 0.0
	wave_active = true
	var enemy_count := get_wave_enemy_count(current_wave_index)
	wave_started.emit(current_wave_index + 1, get_total_wave_count(), enemy_count)
	_emit_progress()

func _emit_progress() -> void:
	wave_progress_changed.emit(
		current_wave_index + 1,
		get_total_wave_count(),
		defeated_in_wave,
		get_wave_enemy_count(current_wave_index)
	)

func _current_config() -> Dictionary:
	if current_wave_index < 0 or current_wave_index >= wave_configs.size():
		return {}
	return wave_configs[current_wave_index]

func get_total_wave_count() -> int:
	return wave_configs.size()

func get_wave_enemy_count(wave_index: int) -> int:
	if wave_index < 0 or wave_index >= wave_configs.size():
		return 0
	return int(wave_configs[wave_index].get("enemy_count", 0))

func get_total_enemy_count() -> int:
	var total := 0
	for config in wave_configs:
		total += int(config.get("enemy_count", 0))
	return total
