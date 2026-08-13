class_name ZombieDog
extends WaveEnemy

enum State {
	RUN,
	TELEGRAPH,
	POUNCE,
	RECOVER,
}

@export var max_health: int = 44
@export var run_speed: float = 168.0
@export var pounce_speed: float = 390.0
@export var gravity: float = 1280.0
@export var pounce_range: float = 210.0
@export var pounce_minimum_range: float = 58.0
@export var pounce_cooldown: float = 1.55
@export var telegraph_duration: float = 0.34
@export var pounce_duration: float = 0.42
@export var recovery_duration: float = 0.28
@export var hurt_duration: float = 0.2
@export var defeated_duration: float = 0.52
@export var contact_damage: int = 16

var health: int
var target: PlayerGirl
var state: State = State.RUN
var state_timer: float = 0.0
var attack_cooldown: float = 0.0
var hurt_timer: float = 0.0
var defeated_timer: float = 0.0
var pounce_direction: float = -1.0
var pounce_hit_consumed: bool = false
var is_dead: bool = false

@onready var character_sprite: AnimatedSprite2D = $CharacterSprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	health = max_health
	attack_cooldown = pounce_cooldown * 0.55
	add_to_group("enemies")
	_update_animation()

func _physics_process(delta: float) -> void:
	if is_dead:
		defeated_timer = maxf(0.0, defeated_timer - delta)
		if defeated_timer <= 0.0:
			queue_free()
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as PlayerGirl
	_update_facing()
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	hurt_timer = maxf(0.0, hurt_timer - delta)
	update_support_buff(delta)

	if hurt_timer > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, run_speed * 5.0 * delta)
	else:
		_update_state(delta)

	move_and_slide()
	_apply_pounce_contact_damage()
	_update_animation()

func _update_state(delta: float) -> void:
	if not is_instance_valid(target) or target.is_dead:
		velocity.x = move_toward(velocity.x, 0.0, run_speed * 4.0 * delta)
		return

	match state:
		State.RUN:
			var distance_x := target.global_position.x - global_position.x
			velocity.x = signf(distance_x) * run_speed * get_support_speed_multiplier()
			if attack_cooldown <= 0.0 and absf(distance_x) <= pounce_range and absf(distance_x) >= pounce_minimum_range:
				_begin_telegraph()
		State.TELEGRAPH:
			velocity.x = 0.0
			state_timer = maxf(0.0, state_timer - delta)
			if state_timer <= 0.0:
				_begin_pounce()
		State.POUNCE:
			velocity.x = pounce_direction * pounce_speed * get_support_speed_multiplier()
			state_timer = maxf(0.0, state_timer - delta)
			if state_timer <= 0.0:
				_begin_recovery()
		State.RECOVER:
			if is_instance_valid(target):
				var distance_x := target.global_position.x - global_position.x
				velocity.x = signf(distance_x) * run_speed * 0.72 * get_support_speed_multiplier()
			state_timer = maxf(0.0, state_timer - delta)
			if state_timer <= 0.0:
				state = State.RUN

func _begin_telegraph() -> void:
	state = State.TELEGRAPH
	state_timer = telegraph_duration
	pounce_hit_consumed = false

func _begin_pounce() -> void:
	state = State.POUNCE
	state_timer = pounce_duration
	if is_instance_valid(target):
		pounce_direction = signf(target.global_position.x - global_position.x)
	if is_zero_approx(pounce_direction):
		pounce_direction = -1.0
	velocity.y = -155.0

func _begin_recovery() -> void:
	state = State.RECOVER
	state_timer = recovery_duration
	pounce_hit_consumed = true
	attack_cooldown = pounce_cooldown

func _apply_pounce_contact_damage() -> void:
	if state != State.POUNCE or pounce_hit_consumed:
		return
	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		var collider := collision.get_collider() as Node
		if collider is PlayerGirl:
			var player := collider as PlayerGirl
			player.take_damage(contact_damage, Vector2(pounce_direction, -0.12))
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
	state_timer = recovery_duration
	pounce_hit_consumed = true
	attack_cooldown = pounce_cooldown
	velocity += knockback_direction.normalized() * 120.0
	_update_animation()

func _update_animation() -> void:
	if not is_instance_valid(character_sprite):
		return
	if is_dead:
		character_sprite.play(&"defeated")
	elif hurt_timer > 0.0:
		character_sprite.play(&"hurt")
	elif state == State.TELEGRAPH or state == State.POUNCE:
		character_sprite.play(&"pounce")
	elif absf(velocity.x) > 0.1:
		character_sprite.play(&"run")
	else:
		character_sprite.play(&"idle")
