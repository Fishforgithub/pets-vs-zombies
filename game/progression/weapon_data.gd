class_name WeaponData
extends Resource

@export var weapon_id: StringName
@export var display_name: String = "Weapon"
@export var base_damage: int = 20
@export var damage_per_level: int = 5
@export var fire_interval: float = 0.2
@export var magazine_size: int = 12
@export var reload_duration: float = 0.8
@export var purchase_price: int = 0
@export var unlock_level: int = 1
@export var upgrade_base_cost: int = 40
@export var max_level: int = 5

func damage_at(level: int) -> int:
	return base_damage + maxi(0, level - 1) * damage_per_level

func upgrade_cost(current_level: int) -> int:
	if current_level <= 0 or current_level >= max_level:
		return -1
	return upgrade_base_cost * current_level
