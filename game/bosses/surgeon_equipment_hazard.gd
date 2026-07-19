class_name SurgeonEquipmentHazard
extends Area2D

@export var speed: float = 330.0
@export var damage: int = 22
@export var lifetime: float = 4.5

var travel_direction: float = -1.0
var targets_hit: Dictionary = {}

@onready var equipment_sprite: AnimatedSprite2D = $EquipmentSprite

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	equipment_sprite.flip_h = travel_direction > 0.0
	equipment_sprite.play(&"roll")

func configure(direction: float, configured_damage: int, configured_speed: float) -> void:
	travel_direction = 1.0 if direction >= 0.0 else -1.0
	damage = configured_damage
	speed = configured_speed

func _physics_process(delta: float) -> void:
	global_position.x += travel_direction * speed * delta
	lifetime = maxf(0.0, lifetime - delta)
	if lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if not body is PlayerGirl or targets_hit.has(body):
		return
	targets_hit[body] = true
	(body as PlayerGirl).take_damage(damage, Vector2(travel_direction, -0.3))
