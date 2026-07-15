class_name PlayerGirl
extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal ammo_changed(current: int, maximum: int)
signal died

const BULLET_SCENE := preload("res://game/projectiles/bullet.tscn")

@export var move_speed: float = 250.0
@export var jump_velocity: float = -470.0
@export var gravity: float = 1280.0
@export var max_health: int = 100
@export var magazine_size: int = 24
@export var fire_interval: float = 0.12

var health: int
var ammo: int
var aim_direction: Vector2 = Vector2.RIGHT
var fire_cooldown: float = 0.0
var is_crouching: bool = false
var is_dead: bool = false

func _ready() -> void:
	health = max_health
	ammo = magazine_size
	add_to_group("player")
	health_changed.emit(health, max_health)
	ammo_changed.emit(ammo, magazine_size)
	queue_redraw()

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	var axis := Input.get_axis("move_left", "move_right")
	is_crouching = Input.is_action_pressed("crouch") and is_on_floor()
	velocity.x = axis * (move_speed * 0.45 if is_crouching else move_speed)

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = jump_velocity

	var mouse_delta := get_global_mouse_position() - global_position
	if mouse_delta.length_squared() > 1.0:
		aim_direction = mouse_delta.normalized()

	fire_cooldown = maxf(0.0, fire_cooldown - delta)
	if Input.is_action_pressed("fire"):
		_try_fire()
	if Input.is_action_just_pressed("reload"):
		reload()

	move_and_slide()
	queue_redraw()

func _try_fire() -> void:
	if fire_cooldown > 0.0:
		return
	if ammo <= 0:
		reload()
		return

	var bullet := BULLET_SCENE.instantiate() as GameBullet
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + aim_direction * 28.0 + Vector2(0.0, -18.0)
	bullet.configure(aim_direction, &"enemies", 25, Color("ffe066"))
	ammo -= 1
	fire_cooldown = fire_interval
	ammo_changed.emit(ammo, magazine_size)

func reload() -> void:
	if ammo == magazine_size or is_dead:
		return
	ammo = magazine_size
	ammo_changed.emit(ammo, magazine_size)

func take_damage(amount: int, knockback_direction: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return
	health = maxi(0, health - amount)
	velocity += knockback_direction.normalized() * 110.0
	health_changed.emit(health, max_health)
	if health <= 0:
		is_dead = true
		velocity = Vector2.ZERO
		died.emit()
	queue_redraw()

func _draw() -> void:
	var production_sprite := get_node_or_null("CharacterSprite") as Sprite2D
	if is_instance_valid(production_sprite) and production_sprite.texture != null:
		return
	# Temporary code-drawn pixel character. Production art will replace this.
	var crouch_offset := 9.0 if is_crouching else 0.0
	var body_color := Color("4dabf7") if not is_dead else Color("868e96")
	var skin := Color("ffd8a8")
	var hair := Color("4a2f24")

	draw_rect(Rect2(-10, -38 + crouch_offset, 20, 22), body_color)
	draw_rect(Rect2(-9, -54 + crouch_offset, 18, 17), skin)
	draw_rect(Rect2(-11, -57 + crouch_offset, 22, 8), hair)
	draw_rect(Rect2(-11, -50 + crouch_offset, 5, 15), hair)
	draw_rect(Rect2(-8, -16 + crouch_offset, 6, 16 - crouch_offset), Color("343a40"))
	draw_rect(Rect2(3, -16 + crouch_offset, 6, 16 - crouch_offset), Color("343a40"))

	var muzzle := aim_direction * 30.0 + Vector2(0, -27 + crouch_offset)
	draw_line(Vector2(0, -27 + crouch_offset), muzzle, Color("495057"), 6.0)
	draw_circle(muzzle, 3.0, Color("212529"))
