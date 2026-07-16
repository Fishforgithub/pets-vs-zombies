class_name RunProgression
extends Node

signal progress_changed(level: int, experience: int, experience_required: int, currency: int)
signal level_increased(new_level: int)
signal upgrades_changed

const STARTER_WEAPON: WeaponData = preload("res://game/data/weapons/starter_pistol.tres")
const ENERGY_BOLT: PetSkillData = preload("res://game/data/pet_skills/energy_bolt.tres")

@export var level: int = 1
@export var experience: int = 0
@export var currency: int = 0

var weapon_levels: Dictionary = {&"starter_pistol": 1}
var pet_skill_levels: Dictionary = {&"energy_bolt": 1}

func _ready() -> void:
	_emit_progress()

func award_rewards(experience_reward: int, currency_reward: int) -> void:
	experience += maxi(0, experience_reward)
	currency += maxi(0, currency_reward)
	while experience >= experience_required_for_next_level():
		experience -= experience_required_for_next_level()
		level += 1
		level_increased.emit(level)
	_emit_progress()

func experience_required_for_next_level() -> int:
	return 80 + maxi(0, level - 1) * 45

func get_weapon_level(weapon_id: StringName) -> int:
	return int(weapon_levels.get(weapon_id, 0))

func get_pet_skill_level(skill_id: StringName) -> int:
	return int(pet_skill_levels.get(skill_id, 0))

func try_purchase_weapon(data: WeaponData) -> bool:
	if data == null or get_weapon_level(data.weapon_id) > 0:
		return false
	if level < data.unlock_level or currency < data.purchase_price:
		return false
	currency -= data.purchase_price
	weapon_levels[data.weapon_id] = 1
	upgrades_changed.emit()
	_emit_progress()
	return true

func try_upgrade_weapon(data: WeaponData) -> bool:
	if data == null or level < data.unlock_level:
		return false
	var current_level := get_weapon_level(data.weapon_id)
	var cost := data.upgrade_cost(current_level)
	if cost < 0 or currency < cost:
		return false
	currency -= cost
	weapon_levels[data.weapon_id] = current_level + 1
	upgrades_changed.emit()
	_emit_progress()
	return true

func try_purchase_pet_skill(data: PetSkillData) -> bool:
	if data == null or get_pet_skill_level(data.skill_id) > 0:
		return false
	if level < data.unlock_level or currency < data.purchase_price:
		return false
	currency -= data.purchase_price
	pet_skill_levels[data.skill_id] = 1
	upgrades_changed.emit()
	_emit_progress()
	return true

func try_upgrade_pet_skill(data: PetSkillData) -> bool:
	if data == null or level < data.unlock_level:
		return false
	var current_level := get_pet_skill_level(data.skill_id)
	var cost := data.upgrade_cost(current_level)
	if cost < 0 or currency < cost:
		return false
	currency -= cost
	pet_skill_levels[data.skill_id] = current_level + 1
	upgrades_changed.emit()
	_emit_progress()
	return true

func _emit_progress() -> void:
	progress_changed.emit(level, experience, experience_required_for_next_level(), currency)
