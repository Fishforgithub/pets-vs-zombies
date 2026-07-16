class_name ForemanBoss
extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal defeated(boss: ForemanBoss)

enum State {
	CHASE,
	SWEEP,
	HURT,
	DEFEATED,
}

@export var max_health: int = 650
@export var move_speed: float = 58.0
@export var gravity: float = 1280.0
@export var sweep_damage: int = 24
@export var sweep_range: float = 145.0
@export var attack_interval: float = 1.25
@export var hurt_duration: float = 0.18
@export var defeat_delay: float = 0.9

var health: int
var target: PlayerGirl
var state: State = State.CHASE
var attack_cooldown: float = 0.45
var hurt_timer: float = 0.0
var facing_direction: float = -1.0
var sweep_targets_hit: Dictionary = {}
var defeat_emitted: bool = false

@onready var body_collision: CollisionShape2D = $BodyCollision
@onready var vulnerable_area: Area2D = $VulnerableArea
@onready var vulnerable_collision: CollisionShape2D = $VulnerableArea/VulnerableCollision
@onready var sweep_area: Area2D = $SweepArea
@onready var sweep_collision: CollisionShape2D = $SweepArea/SweepCollision
@onready var character_sprite: AnimatedSprite2D = $CharacterSprite

func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	character_sprite.animation_finished.connect(_on_animation_finished)
	character_sprite.frame_changed.connect(_on_animation_frame_changed)
	sweep_area.body_entered.connect(_on_sweep_body_entered)
	health_changed.emit(health, max_health)
	character_sprite.play(&"idle")

func _physics_process(delta: float) -> void:
	if state == State.DEFEATED:
		velocity = Vector2.ZERO
		return
	if not is_on_floor():
		velocity.y += gravity * delta
	attack_cooldown = maxf(0.0, attack_cooldown - delta)

	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player") as PlayerGirl
	if is_instance_valid(target):
		_update_facing(target.global_position.x - global_position.x)

	if state == State.SWEEP:
		velocity.x = 0.0
		move_and_slide()
		return
	if state == State.HURT:
		hurt_timer = maxf(0.0, hurt_timer - delta)
		velocity.x = move_toward(velocity.x, 0.0, move_speed * 8.0 * delta)
		move_and_slide()
		if hurt_timer <= 0.0:
			state = State.CHASE
		return

	if not is_instance_valid(target) or target.is_dead:
		velocity.x = 0.0
		character_sprite.play(&"idle")
		move_and_slide()
		return

	var distance_x := target.global_position.x - global_position.x
	if absf(distance_x) <= sweep_range and attack_cooldown <= 0.0:
		_start_sweep()
	elif absf(distance_x) > sweep_range * 0.72:
		velocity.x = signf(distance_x) * move_speed
		character_sprite.play(&"walk")
	else:
		velocity.x = 0.0
		character_sprite.play(&"idle")
	move_and_slide()

func take_damage(amount: int, knockback_direction: Vector2 = Vector2.ZERO) -> void:
	if state == State.DEFEATED:
		return
	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)
	if health <= 0:
		_enter_defeated()
		return
	state = State.HURT
	hurt_timer = hurt_duration
	velocity += knockback_direction.normalized() * 45.0
	character_sprite.play(&"hurt")

func _start_sweep() -> void:
	state = State.SWEEP
	velocity.x = 0.0
	sweep_targets_hit.clear()
	_set_sweep_active(false)
	character_sprite.play(&"sweep")

func _update_facing(distance_x: float) -> void:
	if absf(distance_x) <= 0.1:
		return
	facing_direction = 1.0 if distance_x > 0.0 else -1.0
	character_sprite.flip_h = facing_direction > 0.0
	sweep_area.position.x = 92.0 * facing_direction

func _on_animation_frame_changed() -> void:
	var sweep_is_active := state == State.SWEEP and character_sprite.animation == &"sweep" and character_sprite.frame == 2
	_set_sweep_active(sweep_is_active)
	if sweep_is_active:
		call_deferred("_damage_overlapping_sweep_targets")

func _on_animation_finished() -> void:
	if state != State.SWEEP or character_sprite.animation != &"sweep":
		return
	_set_sweep_active(false)
	state = State.CHASE
	attack_cooldown = attack_interval
	character_sprite.play(&"idle")

func _set_sweep_active(active: bool) -> void:
	sweep_collision.set_deferred("disabled", not active)
	if not active:
		sweep_targets_hit.clear()

func _damage_overlapping_sweep_targets() -> void:
	if state != State.SWEEP or character_sprite.frame != 2:
		return
	for body in sweep_area.get_overlapping_bodies():
		_on_sweep_body_entered(body)

func _on_sweep_body_entered(body: Node) -> void:
	if state != State.SWEEP or character_sprite.animation != &"sweep" or character_sprite.frame != 2:
		return
	if not body is PlayerGirl or sweep_targets_hit.has(body):
		return
	sweep_targets_hit[body] = true
	var player := body as PlayerGirl
	player.take_damage(sweep_damage, Vector2(facing_direction, -0.2))

func _enter_defeated() -> void:
	state = State.DEFEATED
	velocity = Vector2.ZERO
	remove_from_group("enemies")
	body_collision.set_deferred("disabled", true)
	vulnerable_collision.set_deferred("disabled", true)
	_set_sweep_active(false)
	character_sprite.play(&"defeated")
	_emit_defeated_after_delay()

func _emit_defeated_after_delay() -> void:
	if defeat_delay > 0.0:
		await get_tree().create_timer(defeat_delay).timeout
	if defeat_emitted:
		return
	defeat_emitted = true
	defeated.emit(self)
