class_name PetSkillData
extends Resource

@export var skill_id: StringName
@export var display_name: String = "Pet Skill"
@export var base_damage: int = 10
@export var damage_per_level: int = 4
@export var base_cooldown: float = 1.0
@export var cooldown_reduction_per_level: float = 0.06
@export var attack_range: float = 430.0
@export var purchase_price: int = 0
@export var unlock_level: int = 1
@export var upgrade_base_cost: int = 35
@export var max_level: int = 5

func damage_at(level: int) -> int:
	return base_damage + maxi(0, level - 1) * damage_per_level

func cooldown_at(level: int) -> float:
	return maxf(0.2, base_cooldown - maxi(0, level - 1) * cooldown_reduction_per_level)

func upgrade_cost(current_level: int) -> int:
	if current_level <= 0 or current_level >= max_level:
		return -1
	return upgrade_base_cost * current_level
