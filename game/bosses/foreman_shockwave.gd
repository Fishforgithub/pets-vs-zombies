class_name ForemanShockwave
extends Area2D

@export var speed: float = 300.0
@export var damage: int = 18

var travel_direction: float = -1.0
var targets_hit: Dictionary = {}

@onready var damage_collision: CollisionShape2D = $DamageCollision
@onready var effect_sprite: AnimatedSprite2D = $EffectSprite

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	effect_sprite.frame_changed.connect(_on_animation_frame_changed)
	effect_sprite.animation_finished.connect(_on_animation_finished)
	effect_sprite.flip_h = travel_direction > 0.0
	effect_sprite.play(&"travel")

func configure(direction: float, configured_damage: int, configured_speed: float) -> void:
	travel_direction = 1.0 if direction >= 0.0 else -1.0
	damage = configured_damage
	speed = configured_speed

func _physics_process(delta: float) -> void:
	global_position.x += travel_direction * speed * delta

func _on_animation_frame_changed() -> void:
	var active := effect_sprite.animation == &"travel" and effect_sprite.frame == 2
	damage_collision.set_deferred("disabled", not active)
	if active:
		call_deferred("_damage_overlapping_targets")

func _damage_overlapping_targets() -> void:
	if effect_sprite.animation != &"travel" or effect_sprite.frame != 2:
		return
	for body in get_overlapping_bodies():
		_on_body_entered(body)

func _on_body_entered(body: Node) -> void:
	if effect_sprite.animation != &"travel" or effect_sprite.frame != 2:
		return
	if not body is PlayerGirl or targets_hit.has(body):
		return
	targets_hit[body] = true
	var player := body as PlayerGirl
	player.take_damage(damage, Vector2(travel_direction, -0.25))

func _on_animation_finished() -> void:
	damage_collision.set_deferred("disabled", true)
	queue_free()
