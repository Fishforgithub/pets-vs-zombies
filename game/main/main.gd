extends Node2D

const ZOMBIE_SCENE := preload("res://game/enemies/zombie.tscn")
const CITY_FAR_PATH := "res://assets/backgrounds/stage1/city_far.png"
const GROUND_TILES_PATH := "res://assets/tilesets/stage1/ground_tiles.png"
const STAGE_WIDTH: float = 2800.0
const GROUND_TILE_SIZE: float = 256.0
const GROUND_TILE_COUNT: int = 4
const GROUND_DRAW_Y: float = 486.0

@export var required_defeats: int = 5

@onready var player: PlayerGirl = $Player
@onready var pet: PetCompanion = $PetCompanion
@onready var hud: GameHud = $Hud
@onready var enemies: Node2D = $Enemies

var defeated_count: int = 0
var finished: bool = false
var production_background_active: bool = false
var ground_tiles_texture: Texture2D

func _ready() -> void:
	_setup_production_art()
	player.health_changed.connect(hud.set_health)
	player.ammo_changed.connect(hud.set_ammo)
	player.died.connect(_on_player_died)
	pet.owner_player = player
	hud.set_health(player.health, player.max_health)
	hud.set_ammo(player.ammo, player.magazine_size)
	hud.set_objective(defeated_count, required_defeats)

	for spawn_x in [760.0, 1120.0, 1480.0, 1850.0, 2220.0]:
		_spawn_zombie(Vector2(spawn_x, 620.0))

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

func _spawn_zombie(spawn_position: Vector2) -> void:
	var zombie := ZOMBIE_SCENE.instantiate() as ZombieEnemy
	enemies.add_child(zombie)
	zombie.global_position = spawn_position
	zombie.defeated.connect(_on_zombie_defeated)

func _on_zombie_defeated(_enemy: ZombieEnemy) -> void:
	defeated_count += 1
	hud.set_objective(defeated_count, required_defeats)
	if defeated_count >= required_defeats and not finished:
		finished = true
		player.is_dead = true
		hud.show_result("STAGE CLEAR!", "The girl and her pet survived the street.")

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
