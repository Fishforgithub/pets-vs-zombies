class_name StageOne
extends Node2D

const ZOMBIE_SCENE := preload("res://game/enemies/zombie.tscn")
const FOREMAN_SCENE := preload("res://game/bosses/foreman_boss.tscn")
const CITY_FAR_PATH := "res://assets/backgrounds/stage1/city_far.png"
const GROUND_TILES_PATH := "res://assets/tilesets/stage1/ground_tiles.png"
const CAMPAIGN_MAP_PATH := "res://game/main/main.tscn"
const STAGE_WIDTH: float = 2800.0
const GROUND_TILE_SIZE: float = 256.0
const GROUND_TILE_COUNT: int = 4
const GROUND_DRAW_Y: float = 486.0
const SPAWN_OFFSET: float = 680.0

@export var persistence_enabled: bool = true

@onready var player: PlayerGirl = $Player
@onready var pet: PetCompanion = $PetCompanion
@onready var hud: GameHud = $Hud
@onready var enemies: Node2D = $Enemies
@onready var wave_director: WaveDirector = $WaveDirector
@onready var stage_result: StageResultScreen = $StageResultScreen

var defeated_count: int = 0
var active_boss: ForemanBoss
var experience_earned: int = 0
var currency_earned: int = 0
var finished: bool = false
var production_background_active: bool = false
var ground_tiles_texture: Texture2D

func _ready() -> void:
	_setup_production_art()
	player.health_changed.connect(hud.set_health)
	player.ammo_changed.connect(hud.set_ammo)
	player.progression.progress_changed.connect(hud.set_progression)
	if persistence_enabled:
		player.progression.load_profile()
	player.died.connect(_on_player_died)
	stage_result.configure_progression(player.progression)
	stage_result.retry_requested.connect(_on_retry_requested)
	stage_result.map_requested.connect(_on_map_requested)
	stage_result.next_stage_requested.connect(_on_next_stage_requested)
	stage_result.upgrade_purchased.connect(_on_upgrade_purchased)
	wave_director.wave_started.connect(_on_wave_started)
	wave_director.wave_progress_changed.connect(_on_wave_progress_changed)
	wave_director.enemy_defeated.connect(_on_zombie_defeated)
	wave_director.all_waves_completed.connect(_on_all_waves_completed)
	pet.owner_player = player
	hud.set_health(player.health, player.max_health)
	hud.set_ammo(player.ammo, player.magazine_size)
	hud.set_progression(player.progression.level, player.progression.experience, player.progression.experience_required_for_next_level(), player.progression.currency)
	wave_director.configure(_spawn_zombie)
	wave_director.start()

func _setup_production_art() -> void:
	if ResourceLoader.exists(CITY_FAR_PATH):
		var background_texture := load(CITY_FAR_PATH) as Texture2D
		if background_texture != null:
			var parallax := Parallax2D.new()
			parallax.name = "ProductionBackground"
			parallax.z_index = -10
			parallax.scroll_scale = Vector2(0.35, 1.0)
			parallax.repeat_size = Vector2(float(background_texture.get_width()), 0.0)
			parallax.repeat_times = 4
			var background_sprite := Sprite2D.new()
			background_sprite.texture = background_texture
			background_sprite.centered = false
			background_sprite.position = Vector2(0.0, 80.0)
			parallax.add_child(background_sprite)
			add_child(parallax)
			move_child(parallax, 0)
			production_background_active = true

	if ResourceLoader.exists(GROUND_TILES_PATH):
		ground_tiles_texture = load(GROUND_TILES_PATH) as Texture2D
	queue_redraw()

func _process(_delta: float) -> void:
	if finished and Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _spawn_zombie(spawn_side: int) -> WaveEnemy:
	var zombie := ZOMBIE_SCENE.instantiate() as ZombieEnemy
	enemies.add_child(zombie)
	var direction := 1.0 if spawn_side >= 0 else -1.0
	var spawn_x := clampf(player.global_position.x + direction * SPAWN_OFFSET, 80.0, STAGE_WIDTH - 80.0)
	zombie.global_position = Vector2(spawn_x, 620.0)
	return zombie

func _on_wave_started(wave_number: int, total_waves: int, enemy_count: int) -> void:
	hud.set_wave(wave_number, total_waves, 0, enemy_count)
	hud.show_wave_banner(wave_number, total_waves)

func _on_wave_progress_changed(wave_number: int, total_waves: int, defeated: int, enemy_count: int) -> void:
	hud.set_wave(wave_number, total_waves, defeated, enemy_count)

func _on_zombie_defeated(enemy: WaveEnemy) -> void:
	defeated_count += 1
	experience_earned += enemy.experience_reward
	currency_earned += enemy.currency_reward
	player.progression.award_rewards(enemy.experience_reward, enemy.currency_reward)

func _on_all_waves_completed() -> void:
	if finished:
		return
	_spawn_foreman()

func _spawn_foreman() -> void:
	active_boss = FOREMAN_SCENE.instantiate() as ForemanBoss
	enemies.add_child(active_boss)
	active_boss.global_position = Vector2(clampf(player.global_position.x + 760.0, 420.0, STAGE_WIDTH - 140.0), 620.0)
	active_boss.target = player
	active_boss.health_changed.connect(_on_foreman_health_changed)
	active_boss.defeated.connect(_on_foreman_defeated)
	hud.show_boss(active_boss.max_health)
	hud.show_boss_banner("UNDEAD FOREMAN")

func _on_foreman_health_changed(current: int, maximum: int) -> void:
	hud.set_boss_health(current, maximum)

func _on_foreman_defeated(boss: ForemanBoss) -> void:
	if finished:
		return
	experience_earned += boss.experience_reward
	currency_earned += boss.currency_reward
	player.progression.award_rewards(boss.experience_reward, boss.currency_reward)
	player.progression.complete_stage(1)
	_save_progression()
	finished = true
	player.is_dead = true
	hud.hide_boss()
	stage_result.show_stage_clear(experience_earned, currency_earned, player.progression.level, 1, ResourceLoader.exists("res://game/stages/stage2.tscn"))

func _on_retry_requested() -> void:
	_save_progression()
	get_tree().reload_current_scene()

func _on_map_requested() -> void:
	_save_progression()
	get_tree().change_scene_to_file(CAMPAIGN_MAP_PATH)

func _on_next_stage_requested(stage_number: int) -> void:
	_save_progression()
	var next_scene_path := "res://game/stages/stage%d.tscn" % stage_number
	if ResourceLoader.exists(next_scene_path):
		get_tree().change_scene_to_file(next_scene_path)
	else:
		get_tree().change_scene_to_file(CAMPAIGN_MAP_PATH)

func _on_upgrade_purchased() -> void:
	_save_progression()

func _save_progression() -> void:
	if persistence_enabled:
		player.progression.save_profile()

func _on_player_died() -> void:
	if finished:
		return
	finished = true
	hud.show_result("TRY AGAIN", "The zombies overwhelmed the team.")

func _draw() -> void:
	if not production_background_active:
		_draw_procedural_background()
	if ground_tiles_texture != null:
		_draw_production_ground()
	else:
		_draw_procedural_ground()

func _draw_procedural_background() -> void:
	draw_rect(Rect2(0, 0, 2800, 720), Color("8ecae6"))
	for x in range(0, 2800, 190):
		var height := 210 + (x / 190 % 3) * 45
		draw_rect(Rect2(x, 620 - height, 165, height), Color("6c757d"))
		for wx in range(x + 18, x + 145, 38):
			for wy in range(int(640 - height), 570, 48):
				draw_rect(Rect2(wx, wy, 18, 23), Color("ffd166"))

func _draw_production_ground() -> void:
	var tile_count := ceili(STAGE_WIDTH / GROUND_TILE_SIZE)
	for index in range(tile_count):
		var source_index := index % GROUND_TILE_COUNT
		var destination := Rect2(index * GROUND_TILE_SIZE, GROUND_DRAW_Y, GROUND_TILE_SIZE, GROUND_TILE_SIZE)
		var source := Rect2(source_index * GROUND_TILE_SIZE, 0.0, GROUND_TILE_SIZE, GROUND_TILE_SIZE)
		draw_texture_rect_region(ground_tiles_texture, destination, source)

func _draw_procedural_ground() -> void:
	draw_rect(Rect2(0, 620, 2800, 100), Color("495057"))
	draw_rect(Rect2(0, 620, 2800, 8), Color("ced4da"))
	for x in range(30, 2800, 100):
		draw_rect(Rect2(x, 674, 56, 5), Color("f8f9fa"))
