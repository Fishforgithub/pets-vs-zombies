class_name GameBullet
extends Area2D

@export var speed: float = 720.0
@export var damage: int = 20
@export var lifetime: float = 1.8
@export var target_group: StringName = &"enemies"
@export var color: Color = Color("ffe066")

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _physics_process(delta: float) -> void:
	global_position += direction.normalized() * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func configure(new_direction: Vector2, new_target_group: StringName, new_damage: int, new_color: Color) -> void:
	direction = new_direction.normalized()
	target_group = new_target_group
	damage = new_damage
	color = new_color
	rotation = direction.angle()
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group(target_group):
		return
	if body.has_method("take_damage"):
		body.take_damage(damage, direction)
	queue_free()

func _draw() -> void:
	draw_rect(Rect2(-7.0, -2.0, 14.0, 4.0), color)
	draw_rect(Rect2(-10.0, -1.0, 4.0, 2.0), color.lightened(0.35))

