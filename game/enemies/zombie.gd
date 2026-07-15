class_name ZombieEnemy
extends CharacterBody2D

signal defeated(enemy: ZombieEnemy)

@export var max_health: int = 70
@export var move_speed: float = 78.0
@export var gravity: float = 1280.0
@export var contact_damage: int = 10
@export var attack_interval: float = 0.8

var health: int
var target: PlayerGirl
var attack_cooldown: float = 0.0
var hit_flash: float = 0.0
var is_dead: bool = false

@onready var character_sprite: AnimatedSprite2D = $CharacterSprite

func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	queue_redraw()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not is_on_floor():
		velocity.y += gravity * delta

	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as PlayerGirl
	if is_instance_valid(character_sprite) and is_instance_valid(target):
		character_sprite.flip_h = target.global_position.x < global_position.x

	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	hit_flash = maxf(0.0, hit_flash - delta)
	if is_instance_valid(character_sprite):
		character_sprite.modulate = Color("ffb3b3") if hit_flash > 0.0 else Color.WHITE
	if is_instance_valid(target) and not target.is_dead:
		var distance_x := target.global_position.x - global_position.x
		if absf(distance_x) > 35.0:
			velocity.x = signf(distance_x) * move_speed
		else:
			velocity.x = 0.0
			if attack_cooldown <= 0.0:
				target.take_damage(contact_damage, Vector2(signf(distance_x), -0.15))
				attack_cooldown = attack_interval
	else:
		velocity.x = 0.0

	move_and_slide()
	queue_redraw()

func take_damage(amount: int, knockback_direction: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return
	health = maxi(0, health - amount)
	hit_flash = 0.12
	velocity += knockback_direction.normalized() * 95.0
	if health <= 0:
		is_dead = true
		remove_from_group("enemies")
		defeated.emit(self)
		queue_free()
	queue_redraw()

func _draw() -> void:
	if is_instance_valid(character_sprite) and character_sprite.sprite_frames != null:
		return
	var skin := Color.WHITE if hit_flash > 0.0 else Color("8ce99a")
	var facing := 1.0
	if is_instance_valid(target) and target.global_position.x < global_position.x:
		facing = -1.0
	draw_rect(Rect2(-13, -43, 26, 30), Color("7048e8"))
	draw_rect(Rect2(-11, -61, 22, 20), skin)
	draw_rect(Rect2(-14, -65, 28, 7), Color("495057"))
	draw_rect(Rect2(5 * facing, -55, 4, 4), Color("c92a2a"))
	draw_rect(Rect2(-12, -13, 8, 13), Color("343a40"))
	draw_rect(Rect2(5, -13, 8, 13), Color("343a40"))
	draw_line(Vector2(10 * facing, -36), Vector2(26 * facing, -29), skin, 7.0)

