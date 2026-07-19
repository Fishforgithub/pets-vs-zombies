class_name ZombieDoctor
extends WaveEnemy

const HOSPITAL_EFFECT := preload("res://game/vfx/stage2_hospital_effect.tscn")

@export var max_health: int = 62
@export var move_speed: float = 48.0
@export var gravity: float = 1280.0
@export var preferred_range: float = 215.0
@export var zap_range: float = 230.0
@export var zap_vertical_tolerance: float = 72.0
@export var zap_damage: int = 10
@export var zap_slow_duration: float = 0.9
@export var zap_speed_multiplier: float = 0.55
@export var zap_cooldown: float = 2.4
@export var zap_duration: float = 0.52
@export var hurt_duration: float = 0.18
@export var defeated_duration: float = 0.5

var health: int
var target: PlayerGirl
var zap_timer: float = 0.0
var zap_cooldown_timer: float = 0.0
var zap_event_consumed: bool = false
var hurt_timer: float = 0.0
var defeated_timer: float = 0.0
var is_dead: bool = false

@onready var character_sprite: AnimatedSprite2D = $CharacterSprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var zap_area: Area2D = $ZapArea
@onready var zap_collision_shape: CollisionShape2D = $ZapArea/CollisionShape2D

func _ready() -> void:
	health = max_health
	zap_cooldown_timer = zap_cooldown * 0.5
	add_to_group("enemies")
	zap_collision_shape.disabled = true
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
	update_support_buff(delta)
	zap_cooldown_timer = maxf(0.0, zap_cooldown_timer - delta)
	hurt_timer = maxf(0.0, hurt_timer - delta)

	if hurt_timer > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, move_speed * 4.0 * delta)
	elif zap_timer > 0.0:
		_process_zap(delta)
	else:
		_update_movement_and_attack()

	move_and_slide()
	_update_animation()

func _update_movement_and_attack() -> void:
	if not is_instance_valid(target) or target.is_dead:
		velocity.x = 0.0
		return
	var distance_x := target.global_position.x - global_position.x
	if absf(distance_x) > preferred_range:
		velocity.x = signf(distance_x) * move_speed * get_support_speed_multiplier()
	elif zap_cooldown_timer <= 0.0:
		_begin_zap()
	else:
		velocity.x = 0.0

func _begin_zap() -> void:
	zap_timer = zap_duration
	zap_event_consumed = false
	velocity.x = 0.0
	zap_collision_shape.disabled = true

func _process_zap(delta: float) -> void:
	velocity.x = 0.0
	zap_timer = maxf(0.0, zap_timer - delta)
	if not zap_event_consumed and zap_timer <= zap_duration * 0.5:
		zap_event_consumed = true
		_resolve_zap()
	if zap_timer <= 0.0:
		zap_cooldown_timer = zap_cooldown
		_disable_zap_area()

func _resolve_zap() -> void:
	zap_collision_shape.disabled = false
	if is_instance_valid(target) and not target.is_dead:
		var offset := target.global_position - global_position
		var facing_sign := 1.0 if character_sprite.flip_h else -1.0
		var is_in_front := offset.x * facing_sign >= 0.0
		if is_in_front and absf(offset.x) <= zap_range and absf(offset.y) <= zap_vertical_tolerance:
			target.take_damage(zap_damage, Vector2(facing_sign, -0.1))
			target.apply_movement_slow(zap_slow_duration, zap_speed_multiplier)
			_spawn_zap_effect(target.global_position + Vector2(0.0, -32.0))
	call_deferred("_disable_zap_area")

func _spawn_zap_effect(effect_position: Vector2) -> void:
	if get_tree().current_scene == null:
		return
	var effect := HOSPITAL_EFFECT.instantiate() as Stage2HospitalEffect
	get_tree().current_scene.add_child(effect)
	effect.global_position = effect_position
	effect.configure(0, 0.24)

func _disable_zap_area() -> void:
	zap_collision_shape.disabled = true

func _update_facing() -> void:
	if not is_instance_valid(character_sprite) or not is_instance_valid(target):
		return
	var distance_x := target.global_position.x - global_position.x
	if absf(distance_x) <= 0.1:
		return
	var faces_right := distance_x > 0.0
	character_sprite.flip_h = faces_right
	zap_area.position.x = zap_range * 0.5 if faces_right else -zap_range * 0.5

func take_damage(amount: int, knockback_direction: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return
	health = maxi(0, health - amount)
	zap_timer = 0.0
	zap_event_consumed = true
	_disable_zap_area()
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
	velocity += knockback_direction.normalized() * 95.0
	_update_animation()

func _update_animation() -> void:
	if not is_instance_valid(character_sprite):
		return
	if is_dead:
		character_sprite.play(&"defeated")
	elif hurt_timer > 0.0:
		character_sprite.play(&"hurt")
	elif zap_timer > 0.0:
		character_sprite.play(&"zap")
	elif absf(velocity.x) > 0.1:
		character_sprite.play(&"walk")
	else:
		character_sprite.play(&"idle")
