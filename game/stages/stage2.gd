class_name StageTwo
extends StageOne

const CROW_SCENE := preload("res://game/enemies/stage2/zombie_crow.tscn")
const NURSE_SCENE := preload("res://game/enemies/stage2/zombie_nurse.tscn")
const DOCTOR_SCENE := preload("res://game/enemies/stage2/zombie_doctor.tscn")
const WHEELCHAIR_SCENE := preload("res://game/enemies/stage2/wheelchair_zombie.tscn")
const DOG_SCENE := preload("res://game/enemies/stage2/zombie_dog.tscn")
const CHIEF_SURGEON_SCENE := preload("res://game/bosses/chief_surgeon_boss.tscn")
const HOSPITAL_BACKGROUND_PATH := "res://assets/backgrounds/stage2/hospital_corridor.png"
const HOSPITAL_GROUND_PATH := "res://assets/tilesets/stage2/hospital_ground_tiles.png"
const HOSPITAL_PROPS_PATH := "res://assets/props/stage2/hospital_props.png"

const STAGE_2_WAVES: Array[Dictionary] = [
	{"enemy_count": 3, "spawn_interval": 1.15, "max_alive": 2, "spawn_sides": [1], "enemy_types": [&"nurse", &"crow", &"nurse"]},
	{"enemy_count": 4, "spawn_interval": 0.95, "max_alive": 3, "spawn_sides": [1, -1], "enemy_types": [&"crow", &"nurse", &"dog", &"doctor"]},
	{"enemy_count": 5, "spawn_interval": 0.82, "max_alive": 3, "spawn_sides": [-1, 1], "enemy_types": [&"doctor", &"dog", &"crow", &"doctor", &"nurse"]},
	{"enemy_count": 6, "spawn_interval": 0.68, "max_alive": 4, "spawn_sides": [1, -1], "enemy_types": [&"wheelchair", &"crow", &"dog", &"doctor", &"wheelchair", &"crow"]},
	{"enemy_count": 8, "spawn_interval": 0.55, "max_alive": 5, "spawn_sides": [-1, 1], "enemy_types": [&"wheelchair", &"doctor", &"dog", &"nurse", &"wheelchair", &"crow", &"doctor", &"dog"]},
]

const ENEMY_SCENES: Dictionary = {
	&"crow": CROW_SCENE,
	&"nurse": NURSE_SCENE,
	&"doctor": DOCTOR_SCENE,
	&"wheelchair": WHEELCHAIR_SCENE,
	&"dog": DOG_SCENE,
}

@export var use_stage_two_default_waves: bool = true

func _ready() -> void:
	if use_stage_two_default_waves:
		wave_director.wave_configs = STAGE_2_WAVES.duplicate(true)
	super._ready()

func _setup_production_art() -> void:
	if ResourceLoader.exists(HOSPITAL_BACKGROUND_PATH):
		var background_texture := load(HOSPITAL_BACKGROUND_PATH) as Texture2D
		if background_texture != null:
			var parallax := Parallax2D.new()
			parallax.name = "ProductionBackground"
			parallax.z_index = -10
			parallax.scroll_scale = Vector2(0.45, 1.0)
			parallax.repeat_size = Vector2(float(background_texture.get_width()), 0.0)
			parallax.repeat_times = 5
			var background_sprite := Sprite2D.new()
			background_sprite.texture = background_texture
			background_sprite.centered = false
			background_sprite.position = Vector2(0.0, 80.0)
			parallax.add_child(background_sprite)
			add_child(parallax)
			move_child(parallax, 0)
			production_background_active = true
	if ResourceLoader.exists(HOSPITAL_GROUND_PATH):
		ground_tiles_texture = load(HOSPITAL_GROUND_PATH) as Texture2D
	_add_hospital_props()
	queue_redraw()

func _add_hospital_props() -> void:
	if not ResourceLoader.exists(HOSPITAL_PROPS_PATH):
		return
	var props_texture := load(HOSPITAL_PROPS_PATH) as Texture2D
	var placements := [Vector2(720, 566), Vector2(1450, 566), Vector2(2360, 566)]
	for index in range(placements.size()):
		var prop := Sprite2D.new()
		prop.name = "HospitalProp%d" % index
		prop.texture = props_texture
		prop.region_enabled = true
		prop.region_rect = Rect2(float(index % 4) * 256.0, 0.0, 256.0, 256.0)
		prop.position = placements[index]
		prop.scale = Vector2(0.48, 0.48)
		prop.z_index = -1
		add_child(prop)

func _spawn_zombie(spawn_side: int) -> WaveEnemy:
	var wave_index := wave_director.current_wave_index
	if wave_index < 0 or wave_index >= wave_director.wave_configs.size():
		push_error("Stage 2 attempted to spawn an enemy outside its configured wave range.")
		return null
	var config := wave_director.wave_configs[wave_index]
	var enemy_types := config.get("enemy_types", []) as Array
	if enemy_types.is_empty():
		push_error("Stage 2 wave requires at least one enemy type.")
		return null
	var enemy_type := enemy_types[wave_director.spawned_in_wave % enemy_types.size()] as StringName
	var packed_scene := ENEMY_SCENES.get(enemy_type) as PackedScene
	if packed_scene == null:
		push_error("Stage 2 does not have a scene registered for enemy type %s." % enemy_type)
		return null
	var enemy := packed_scene.instantiate() as WaveEnemy
	enemies.add_child(enemy)
	var direction := 1.0 if spawn_side >= 0 else -1.0
	var spawn_x := clampf(player.global_position.x + direction * SPAWN_OFFSET, 80.0, STAGE_WIDTH - 80.0)
	var spawn_y := 430.0 if enemy is ZombieCrow else 620.0
	enemy.global_position = Vector2(spawn_x, spawn_y)
	return enemy

func _spawn_foreman() -> void:
	active_boss = CHIEF_SURGEON_SCENE.instantiate() as ChiefSurgeonBoss
	enemies.add_child(active_boss)
	active_boss.global_position = Vector2(clampf(player.global_position.x + 760.0, 420.0, STAGE_WIDTH - 140.0), 620.0)
	active_boss.target = player
	active_boss.health_changed.connect(_on_foreman_health_changed)
	active_boss.defeated.connect(_on_chief_surgeon_defeated)
	hud.show_boss(active_boss.max_health)
	hud.show_boss_banner("UNDEAD CHIEF SURGEON")

func _on_chief_surgeon_defeated(boss: ForemanBoss) -> void:
	if finished:
		return
	experience_earned += boss.experience_reward
	currency_earned += boss.currency_reward
	player.progression.award_rewards(boss.experience_reward, boss.currency_reward)
	player.progression.complete_stage(2)
	_save_progression()
	finished = true
	player.is_dead = true
	hud.hide_boss()
	stage_result.show_stage_clear(experience_earned, currency_earned, player.progression.level, 2, false)
