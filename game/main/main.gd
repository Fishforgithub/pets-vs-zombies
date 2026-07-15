extends Node2D

const ZOMBIE_SCENE := preload("res://game/enemies/zombie.tscn")

@export var required_defeats: int = 5

@onready var player: PlayerGirl = $Player
@onready var pet: PetCompanion = $PetCompanion
@onready var hud: GameHud = $Hud
@onready var enemies: Node2D = $Enemies

var defeated_count: int = 0
var finished: bool = false

func _ready() -> void:
	player.health_changed.connect(hud.set_health)
	player.ammo_changed.connect(hud.set_ammo)
	player.died.connect(_on_player_died)
	pet.owner_player = player
	hud.set_health(player.health, player.max_health)
	hud.set_ammo(player.ammo, player.magazine_size)
	hud.set_objective(defeated_count, required_defeats)

	for spawn_x in [760.0, 1120.0, 1480.0, 1850.0, 2220.0]:
		_spawn_zombie(Vector2(spawn_x, 620.0))

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
	# Procedural city graybox background.
	draw_rect(Rect2(0, 0, 2800, 720), Color("8ecae6"))
	for x in range(0, 2800, 190):
		var height := 210 + (x / 190 % 3) * 45
		draw_rect(Rect2(x, 620 - height, 165, height), Color("6c757d"))
		for wx in range(x + 18, x + 145, 38):
			for wy in range(int(640 - height), 570, 48):
				draw_rect(Rect2(wx, wy, 18, 23), Color("ffd166"))
	draw_rect(Rect2(0, 620, 2800, 100), Color("495057"))
	draw_rect(Rect2(0, 620, 2800, 8), Color("ced4da"))
	for x in range(30, 2800, 100):
		draw_rect(Rect2(x, 674, 56, 5), Color("f8f9fa"))

