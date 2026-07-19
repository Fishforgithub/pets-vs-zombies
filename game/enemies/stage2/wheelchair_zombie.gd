class_name WheelchairZombie
extends WaveEnemy

signal shield_blocked(original_damage: int, applied_damage: int)

enum State {
	ROLL,
	WINDUP,
	CHARGE,
	STUNNED,
}

const HOSPITAL_EFFECT := preload("res://game/vfx/stage2_hospital_effect.tscn")

@export var max_health: int = 105
@export var roll_speed: float = 72.0
@export var gravity: float = 1280.0
@export var shield_damage_reduction: float = 0.7
@export var charge_trigger_range: float = 360.0
@export var charge_speed: float = 330.0
@export var charge_windup_duration: float = 0.42
@export var charge_duration: float = 0.85
@export var charge_cooldown: float = 2.6
@export var charge_damage: int = 18
@export var stun_duration: float = 1.15
@export var stun_damage_threshold: int = 14
@export var hurt_duration: float = 0.16
@export var defeated_duration: float = 0.6

var health: int
var target: PlayerGirl
var state: State = State.ROLL
var state_timer: float = 0.0
var charge_cooldown_timer: float = 0.0
var charge_direction: float = -1.0
var charge_hit_consumed: bool = false
var hurt_timer: float = 0.0
var defeated_timer: float = 0.0
var is_dead: bool = false
var shield_enabled: bool = true

@onready var character_sprite: AnimatedSprite2D = $CharacterSprite
@onready var body_collision_shape: CollisionShape2D = $BodyCollisionShape
@onready var shield_area: Area2D = $ShieldArea
@onready var shield_collision_shape: CollisionShape2D = $ShieldArea/CollisionShape2D

func _ready() -> void:
	health = max_health
	charge_cooldown_timer = charge_cooldown
	add_to_group("enemies")
	_set_shield_active(true)
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
	update_support_buff(delta)
	charge_cooldown_timer = maxf(0.0, charge_cooldown_timer - delta)
	hurt_timer = maxf(0.0, hurt_timer - delta)

	match state:
		State.ROLL:
			_update_roll()
		State.WINDUP:
			_process_windup(delta)
		State.CHARGE:
			_process_charge(delta)
		State.STUNNED:
			_process_stunned(delta)

	move_and_slide()
	_resolve_charge_collisions()
	_update_animation()

func _update_roll() -> void:
	if not is_instance_valid(target) or target.is_dead:
		velocity.x = 0.0
		return
	_update_facing(target.global_position.x - global_position.x)
	var distance_x := target.global_position.x - global_position.x
	if charge_cooldown_timer <= 0.0 and absf(distance_x) <= charge_trigger_range:
		_begin_windup()
		return
	velocity.x = signf(distance_x) * roll_speed * get_support_speed_multiplier()

func _begin_windup() -> void:
	state = State.WINDUP
	state_timer = charge_windup_duration
	charge_hit_consumed = false
	velocity.x = 0.0
	charge_direction = 1.0 if character_sprite.flip_h else -1.0

func _process_windup(delta: float) -> void:
	velocity.x = 0.0
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0:
		state = State.CHARGE
		state_timer = charge_duration

func _process_charge(delta: float) -> void:
	velocity.x = charge_direction * charge_speed * get_support_speed_multiplier()
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer <= 0.0:
		_enter_stunned()

func _process_stunned(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, charge_speed * 3.0 * delta)
	state_timer = maxf(0.0, state_timer - delta)
	if state_timer > 0.0:
		return
	state = State.ROLL
	charge_cooldown_timer = charge_cooldown
	_set_shield_active(true)

func _resolve_charge_collisions() -> void:
	if state != State.CHARGE:
		return
	for index in get_slide_collision_count():
		var collider := get_slide_collision(index).get_collider() as Node
		if collider is PlayerGirl and not charge_hit_consumed:
			charge_hit_consumed = true
			(collider as PlayerGirl).take_damage(charge_damage, Vector2(charge_direction, -0.12))
			_enter_stunned()
			return
		if collider != self:
			_enter_stunned()
			return

func _enter_stunned() -> void:
	state = State.STUNNED
	state_timer = stun_duration
	charge_hit_consumed = true
	_set_shield_active(false)
	_spawn_skid_effect()

func _set_shield_active(active: bool) -> void:
	shield_enabled = active
	shield_collision_shape.set_deferred("disabled", not active)
	shield_area.monitoring = active
	shield_area.monitorable = active

func _update_facing(distance_x: float) -> void:
	if absf(distance_x) <= 0.1 or state == State.CHARGE:
		return
	var faces_right := distance_x > 0.0
	character_sprite.flip_h = faces_right
	shield_area.position.x = 34.0 if faces_right else -34.0

func take_damage(amount: int, knockback_direction: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return
	var incoming_direction := signf(knockback_direction.x)
	var facing_direction := 1.0 if character_sprite.flip_h else -1.0
	var shield_active := state != State.STUNNED and shield_enabled
	var is_frontal_hit := incoming_direction != 0.0 and incoming_direction * facing_direction < 0.0
	var applied_damage := amount
	if shield_active and is_frontal_hit:
		applied_damage = maxi(1, ceili(amount * (1.0 - shield_damage_reduction)))
		shield_blocked.emit(amount, applied_damage)

	health = maxi(0, health - applied_damage)
	if health <= 0:
		is_dead = true
		defeated_timer = defeated_duration
		velocity = Vector2.ZERO
		collision_layer = 0
		collision_mask = 0
		body_collision_shape.set_deferred("disabled", true)
		_set_shield_active(false)
		remove_from_group("enemies")
		character_sprite.play(&"defeated")
		defeated.emit(self)
		return

	if state == State.CHARGE:
		velocity.x *= 0.35
		if not is_frontal_hit or applied_damage >= stun_damage_threshold:
			_enter_stunned()
		else:
			state = State.ROLL
			charge_cooldown_timer = charge_cooldown
	hurt_timer = hurt_duration
	_update_animation()

func _spawn_skid_effect() -> void:
	if get_tree().current_scene == null:
		return
	var effect := HOSPITAL_EFFECT.instantiate() as Stage2HospitalEffect
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position + Vector2(-22.0 * charge_direction, -8.0)
	effect.flip_h = charge_direction > 0.0
	effect.configure(2, 0.32)

func _update_animation() -> void:
	if not is_instance_valid(character_sprite):
		return
	if is_dead:
		character_sprite.play(&"defeated")
	elif state == State.STUNNED:
		character_sprite.play(&"stunned")
	elif hurt_timer > 0.0:
		character_sprite.play(&"hurt")
	elif state == State.WINDUP or state == State.CHARGE:
		character_sprite.play(&"charge")
	else:
		character_sprite.play(&"roll")
