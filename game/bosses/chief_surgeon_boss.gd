class_name ChiefSurgeonBoss
extends ForemanBoss

const EQUIPMENT_HAZARD_SCENE := preload("res://game/bosses/surgeon_equipment_hazard.tscn")
const HOSPITAL_EFFECT_SCENE := preload("res://game/vfx/stage2_hospital_effect.tscn")

var phase_two: bool = false

func take_damage(amount: int, knockback_direction: Vector2 = Vector2.ZERO) -> void:
	super.take_damage(amount, knockback_direction)
	if state == State.DEFEATED or phase_two or health > max_health / 2:
		return
	phase_two = true
	move_speed *= 1.3
	attack_interval *= 0.72
	shockwave_speed *= 1.18
	character_sprite.play(&"rage")

func _resolve_slam_impact() -> void:
	if state != State.SLAM or character_sprite.animation != &"slam" or character_sprite.frame != 2:
		return
	var effect := HOSPITAL_EFFECT_SCENE.instantiate() as Stage2HospitalEffect
	get_parent().add_child(effect)
	effect.global_position = global_position + Vector2(58.0 * facing_direction, -20.0)
	effect.configure(3, 0.3)
	super._resolve_slam_impact()

func _spawn_shockwave(direction: float) -> void:
	var hazard := EQUIPMENT_HAZARD_SCENE.instantiate() as SurgeonEquipmentHazard
	hazard.configure(direction, shockwave_damage, shockwave_speed)
	get_parent().add_child(hazard)
	hazard.global_position = global_position + Vector2(82.0 * direction, 0.0)
	shockwave_spawned.emit(hazard)
