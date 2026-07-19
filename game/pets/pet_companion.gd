class_name PetCompanion
extends CharacterBody2D

const BULLET_SCENE := preload("res://game/projectiles/bullet.tscn")
const ENERGY_BOLT: PetSkillData = preload("res://game/data/pet_skills/energy_bolt.tres")

@export var follow_offset: Vector2 = Vector2(-72.0, -8.0)
@export var follow_speed: float = 310.0
@export var attack_range: float = 430.0
@export var attack_interval: float = 0.85

var owner_player: PlayerGirl
var attack_cooldown: float = 0.0
var facing_right: bool = true

func _ready() -> void:
	add_to_group("pets")
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(owner_player):
		owner_player = get_tree().get_first_node_in_group("player") as PlayerGirl
		if not is_instance_valid(owner_player):
			return

	var desired := owner_player.global_position + follow_offset
	var delta_to_owner := desired - global_position
	if delta_to_owner.length() > 600.0:
		global_position = desired
		velocity = Vector2.ZERO
	elif delta_to_owner.length() > 24.0:
		velocity = delta_to_owner.normalized() * minf(follow_speed, delta_to_owner.length() * 5.0)
		move_and_slide()
	else:
		velocity = Vector2.ZERO

	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	var target := _nearest_enemy()
	if is_instance_valid(target):
		facing_right = target.global_position.x >= global_position.x
		if attack_cooldown <= 0.0:
			_fire_at(target)
	queue_redraw()

func _nearest_enemy() -> Node2D:
	var nearest: Node2D
	var nearest_distance := ENERGY_BOLT.attack_range
	for candidate in get_tree().get_nodes_in_group("enemies"):
		if not candidate is Node2D:
			continue
		var distance := global_position.distance_to(candidate.global_position)
		if distance < nearest_distance:
			nearest = candidate
			nearest_distance = distance
	return nearest

func _fire_at(target: Node2D) -> void:
	var shot_direction := (target.global_position + Vector2(0, -24) - global_position).normalized()
	var bullet := BULLET_SCENE.instantiate() as GameBullet
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + shot_direction * 22.0 + Vector2(0, -18)
	bullet.speed = 560.0
	var skill_level := owner_player.progression.get_pet_skill_level(ENERGY_BOLT.skill_id)
	bullet.configure(shot_direction, &"enemies", ENERGY_BOLT.damage_at(skill_level), Color("74c0fc"), 2)
	attack_cooldown = ENERGY_BOLT.cooldown_at(skill_level)

func _draw() -> void:
	# Aqua-like temporary companion silhouette; production pet art will replace it.
	var flip := 1.0 if facing_right else -1.0
	draw_circle(Vector2(0, -18), 18.0, Color("4dabf7"))
	draw_circle(Vector2(6 * flip, -21), 3.0, Color.WHITE)
	draw_circle(Vector2(7 * flip, -21), 1.5, Color("1c7ed6"))
	draw_polygon(PackedVector2Array([
		Vector2(-14 * flip, -20), Vector2(-30 * flip, -28), Vector2(-19 * flip, -10)
	]), PackedColorArray([Color("74c0fc")]))
	draw_rect(Rect2(-10, -3, 7, 5), Color("228be6"))
	draw_rect(Rect2(4, -3, 7, 5), Color("228be6"))
