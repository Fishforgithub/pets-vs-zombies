class_name BandageProjectile
extends Area2D

@export var speed: float = 285.0
@export var damage: int = 8
@export var lifetime: float = 3.0
@export var arc_gravity: float = 180.0

var velocity: Vector2 = Vector2.LEFT * 285.0
var hit_consumed: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

func configure(direction: Vector2, new_damage: int) -> void:
	velocity = direction.normalized() * speed
	damage = new_damage
	rotation = velocity.angle()

func _physics_process(delta: float) -> void:
	velocity.y += arc_gravity * delta
	global_position += velocity * delta
	rotation += delta * 7.0
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if hit_consumed or not body is PlayerGirl:
		return
	hit_consumed = true
	var player := body as PlayerGirl
	player.take_damage(damage, velocity)
	queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 7.0, Color("f1f3f5"))
	draw_rect(Rect2(-7.0, -2.0, 14.0, 4.0), Color("ff8787"))
