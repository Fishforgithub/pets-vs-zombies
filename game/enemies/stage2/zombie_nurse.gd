class_name ZombieNurse
extends WaveEnemy

signal support_buff_requested(source: ZombieNurse, radius: float, duration: float, speed_multiplier: float)

enum Action {
	NONE,
	THROW,
	BUFF,
}

const BANDAGE_PROJECTILE := preload("res://game/projectiles/bandage_projectile.tscn")

@export var max_health: int = 52
@export var move_speed: float = 58.0
@export var gravity: float = 1280.0
@export var preferred_range: float = 270.0
@export var throw_cooldown: float = 1.8
@export var throw_duration: float = 0.46
@export var bandage_damage: int = 8
@export var buff_cooldown: float = 5.5
@export var buff_duration: float = 3.5
@export var buff_radius: float = 210.0
@export var buff_speed_multiplier: float = 1.25
@export var hurt_duration: float = 0.18
@export var defeated_duration: float = 0.5

var health: int
var target: PlayerGirl
var active_action: Action = Action.NONE
var action_timer: float = 0.0
var action_event_consumed: bool = false
var attack_cooldown: float = 0.0
var support_cooldown: float = 0.0
var hurt_timer: float = 0.0
var defeated_timer: float = 0.0
var is_dead: bool = false

@onready var character_sprite: AnimatedSprite2D = $CharacterSprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	health = max_health
	attack_cooldown = throw_cooldown * 0.5
	support_cooldown = buff_cooldown
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
	support_cooldown = maxf(0.0, support_cooldown - delta)
	hurt_timer = maxf(0.0, hurt_timer - delta)
	update_support_buff(delta)

	if hurt_timer > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, move_speed * 4.0 * delta)
	elif active_action != Action.NONE:
		_process_action(delta)
	else:
		_update_movement_and_actions()

	move_and_slide()
	_update_animation()

func _update_movement_and_actions() -> void:
	if not is_instance_valid(target) or target.is_dead:
		velocity.x = 0.0
		return
	var distance_x := target.global_position.x - global_position.x
	if absf(distance_x) > preferred_range:
		velocity.x = signf(distance_x) * move_speed * get_support_speed_multiplier()
		return
	velocity.x = 0.0
	if support_cooldown <= 0.0 and _has_nearby_ally():
		_begin_action(Action.BUFF, throw_duration)
	elif attack_cooldown <= 0.0:
		_begin_action(Action.THROW, throw_duration)

func _begin_action(action: Action, duration: float) -> void:
	active_action = action
	action_timer = duration
	action_event_consumed = false
	velocity.x = 0.0

func _process_action(delta: float) -> void:
	velocity.x = 0.0
	action_timer = maxf(0.0, action_timer - delta)
	if not action_event_consumed and action_timer <= throw_duration * 0.5:
		action_event_consumed = true
		if active_action == Action.THROW:
			_release_bandage()
		elif active_action == Action.BUFF:
			_apply_support_buff()
	if action_timer > 0.0:
		return
	if active_action == Action.THROW:
		attack_cooldown = throw_cooldown
	elif active_action == Action.BUFF:
		support_cooldown = buff_cooldown
	active_action = Action.NONE
	action_event_consumed = false

func _release_bandage() -> void:
	if not is_instance_valid(target) or get_tree().current_scene == null:
		return
	var direction := global_position.direction_to(target.global_position + Vector2(0.0, -30.0))
	var projectile := BANDAGE_PROJECTILE.instantiate() as BandageProjectile
	get_tree().current_scene.add_child(projectile)
	var facing_sign := 1.0 if direction.x >= 0.0 else -1.0
	projectile.global_position = global_position + Vector2(25.0 * facing_sign, -38.0)
	projectile.configure(direction, bandage_damage)

func _has_nearby_ally() -> bool:
	for candidate in get_tree().get_nodes_in_group("enemies"):
		if candidate == self or not candidate is WaveEnemy:
			continue
		if global_position.distance_to((candidate as WaveEnemy).global_position) <= buff_radius:
			return true
	return false

func _apply_support_buff() -> void:
	for candidate in get_tree().get_nodes_in_group("enemies"):
		if candidate == self or not candidate is WaveEnemy:
			continue
		var ally := candidate as WaveEnemy
		if global_position.distance_to(ally.global_position) <= buff_radius:
			ally.apply_support_buff(buff_duration, buff_speed_multiplier)
	support_buff_requested.emit(self, buff_radius, buff_duration, buff_speed_multiplier)

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
	active_action = Action.NONE
	action_event_consumed = true
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
	elif active_action == Action.THROW:
		character_sprite.play(&"throw")
	elif active_action == Action.BUFF:
		character_sprite.play(&"buff")
	elif absf(velocity.x) > 0.1:
		character_sprite.play(&"walk")
	else:
		character_sprite.play(&"idle")
