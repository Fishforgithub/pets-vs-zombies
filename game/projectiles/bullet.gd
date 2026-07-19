class_name GameBullet
extends Area2D

const COMBAT_HIT_EFFECT := preload("res://game/vfx/combat_hit_effect.tscn")

@export var speed: float = 720.0
@export var damage: int = 20
@export var lifetime: float = 1.8
@export var target_group: StringName = &"enemies"
@export var color: Color = Color("ffe066")
@export_range(0, 3) var impact_effect_index: int = 1

var direction: Vector2 = Vector2.RIGHT
var hit_consumed: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	queue_redraw()

func _physics_process(delta: float) -> void:
	global_position += direction.normalized() * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func configure(new_direction: Vector2, new_target_group: StringName, new_damage: int, new_color: Color, new_impact_effect_index: int = 1) -> void:
	direction = new_direction.normalized()
	target_group = new_target_group
	damage = new_damage
	color = new_color
	impact_effect_index = clampi(new_impact_effect_index, 0, 3)
	rotation = direction.angle()
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	_try_damage(body)

func _on_area_entered(area: Area2D) -> void:
	_try_damage(area)

func _try_damage(hit_node: Node) -> void:
	if hit_consumed:
		return
	var damage_target := hit_node
	if not damage_target.is_in_group(target_group):
		var parent := damage_target.get_parent()
		if parent == null or not parent.is_in_group(target_group):
			return
		damage_target = parent
	if not damage_target.has_method("take_damage"):
		return
	hit_consumed = true
	damage_target.take_damage(damage, direction)
	_spawn_impact_effect()
	queue_free()

func _spawn_impact_effect() -> void:
	if get_tree().current_scene == null:
		return
	var effect := COMBAT_HIT_EFFECT.instantiate() as CombatHitEffect
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position
	effect.configure(impact_effect_index, 0.16)

func _draw() -> void:
	draw_rect(Rect2(-7.0, -2.0, 14.0, 4.0), color)
	draw_rect(Rect2(-10.0, -1.0, 4.0, 2.0), color.lightened(0.35))
