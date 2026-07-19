class_name ZombieCrow
extends CharacterBody2D

signal defeated(enemy: ZombieCrow)

enum State {
	HOVER,
	TELEGRAPH,
	DIVE,
	RECOVER,
}

@export var max_health: int = 35
@export var flight_speed: float = 90.0
@export var dive_speed: float = 310.0
@export var recovery_speed: float = 150.0
@export var hover_height: float = 145.0
@export var dive_range: float = 250.0
@export var dive_cooldown: float = 1.4
@export var telegraph_duration: float = 0.32
@export var dive_duration: float = 0.62
@export var hurt_duration: float = 0.18
@export var defeated_duration: float = 0.55
@export var contact_damage: int = 12
@export var experience_reward: int = 20
@export var currency_reward: int = 14

var health: int
var target: PlayerGirl
var state: State = State.HOVER
var state_timer: float = 0.0
var attack_cooldown: float = 0.0
var hurt_timer: float = 0.0
var defeated_timer: float = 0.0
var dive_direction: Vector2 = Vector2.DOWN
var dive_hit_consumed: bool = false
var is_dead: bool = false

@onready var character_sprite: AnimatedSprite2D = $CharacterSprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	health = max_health
	attack_cooldown = dive_cooldown
	add_to_group("enemies")
	_update_animation()

func _physics_process(delta: float) -> void:
	if is_dead:
		defeated_timer = maxf(0.0, defeated_timer - delta)
		if defeated_timer <= 0.0:
			queue_free()
		return

	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as PlayerGirl
	_update_facing()
	hurt_timer = maxf(0.0, hurt_timer - delta)
	attack_cooldown = maxf(0.0, attack_cooldown - delta)

	if hurt_timer > 0.0:
		velocity = velocity.move_toward(Vector2.ZERO, recovery_speed * delta)
	else:
		_update_state(delta)

	move_and_slide()
	_apply_dive_contact_damage()
	_update_animation()

func _update_state(delta: float) -> void:
	if not is_instance_valid(target) or target.is_dead:
		velocity = velocity.move_toward(Vector2.ZERO, flight_speed * delta)
		return

	match state:
		State.HOVER:
			var hover_target := target.global_position + Vector2(0.0, -hover_height)
			velocity = global_position.direction_to(hover_target) * flight_speed
			if attack_cooldown <= 0.0 and absf(target.global_position.x - global_position.x) <= dive_range:
				_begin_telegraph()
		State.TELEGRAPH:
			velocity = Vector2.ZERO
			state_timer = maxf(0.0, state_timer - delta)
			if state_timer <= 0.0:
				_begin_dive()
		State.DIVE:
			velocity = dive_direction * dive_speed
			state_timer = maxf(0.0, state_timer - delta)
			if state_timer <= 0.0:
				_begin_recovery()
		State.RECOVER:
			var recovery_target := target.global_position + Vector2(0.0, -hover_height)
			velocity = global_position.direction_to(recovery_target) * recovery_speed
			if global_position.distance_to(recovery_target) <= 18.0:
				state = State.HOVER
				attack_cooldown = dive_cooldown

func _begin_telegraph() -> void:
	state = State.TELEGRAPH
	state_timer = telegraph_duration
	dive_hit_consumed = false

func _begin_dive() -> void:
	state = State.DIVE
	state_timer = dive_duration
	var destination := target.global_position + Vector2(0.0, -24.0) if is_instance_valid(target) else global_position + Vector2.DOWN
	dive_direction = global_position.direction_to(destination)
	if dive_direction.length_squared() <= 0.01:
		dive_direction = Vector2.DOWN

func _begin_recovery() -> void:
	state = State.RECOVER
	state_timer = 0.0
	dive_hit_consumed = true

func _apply_dive_contact_damage() -> void:
	if state != State.DIVE or dive_hit_consumed:
		return
	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		var collider := collision.get_collider() as Node
		if collider is PlayerGirl:
			var player := collider as PlayerGirl
			player.take_damage(contact_damage, dive_direction)
			dive_hit_consumed = true
			_begin_recovery()
			return

func _update_facing() -> void:
	if not is_instance_valid(character_sprite) or not is_instance_valid(target):
		return
	var distance_x := target.global_position.x - global_position.x
	if absf(distance_x) > 0.1:
		character_sprite.flip_h = distance_x > 0.0

func take_damage(amount: int, knockback_direction: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return
	health = maxi(0, health - amount)
	if health <= 0:
		is_dead = true
		defeated_timer = defeated_duration
		velocity = Vector2.ZERO
		collision_layer = 0
		collision_mask = 0
		collision_shape.set_deferred("disabled", true)
		remove_from_group("enemies")
		character_sprite.play(&"defeated")
		defeated.emit(self)
		return

	hurt_timer = hurt_duration
	state = State.RECOVER
	dive_hit_consumed = true
	velocity = knockback_direction.normalized() * 120.0
	_update_animation()

func _update_animation() -> void:
	if not is_instance_valid(character_sprite):
		return
	if is_dead:
		character_sprite.play(&"defeated")
	elif hurt_timer > 0.0:
		character_sprite.play(&"hurt")
	elif state == State.TELEGRAPH or state == State.DIVE:
		character_sprite.play(&"dive")
	else:
		character_sprite.play(&"fly")
