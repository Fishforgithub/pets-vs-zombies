class_name ElectricPuddle
extends Area2D

@export var damage: int = 16

var targets_hit_this_surge: Dictionary = {}

@onready var damage_collision: CollisionShape2D = $DamageCollision
@onready var puddle_sprite: AnimatedSprite2D = $PuddleSprite

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	puddle_sprite.frame_changed.connect(_on_frame_changed)
	puddle_sprite.play(&"electric_cycle")
	_on_frame_changed()

func _on_frame_changed() -> void:
	var active := puddle_sprite.animation == &"electric_cycle" and puddle_sprite.frame == 2
	damage_collision.set_deferred("disabled", not active)
	if not active:
		targets_hit_this_surge.clear()
	else:
		call_deferred("_damage_overlapping_targets")

func _damage_overlapping_targets() -> void:
	if puddle_sprite.frame != 2:
		return
	for body in get_overlapping_bodies():
		_on_body_entered(body)

func _on_body_entered(body: Node) -> void:
	if puddle_sprite.frame != 2 or not body is PlayerGirl or targets_hit_this_surge.has(body):
		return
	targets_hit_this_surge[body] = true
	(body as PlayerGirl).take_damage(damage, Vector2(0.0, -0.4))
