class_name RunProgression
extends Node

signal progress_changed(level: int, experience: int, experience_required: int, currency: int)
signal level_increased(new_level: int)
signal upgrades_changed
signal profile_loaded
signal profile_saved
signal profile_save_failed(error: Error)

const STARTER_WEAPON: WeaponData = preload("res://game/data/weapons/starter_pistol.tres")
const ENERGY_BOLT: PetSkillData = preload("res://game/data/pet_skills/energy_bolt.tres")
const SAVE_VERSION: int = 1
const DEFAULT_SAVE_PATH: String = "user://campaign_profile.json"

@export var level: int = 1
@export var experience: int = 0
@export var currency: int = 0

var weapon_levels: Dictionary = {&"starter_pistol": 1}
var pet_skill_levels: Dictionary = {&"energy_bolt": 1}
var save_path: String = DEFAULT_SAVE_PATH

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

func save_profile(path_override: String = "") -> Error:
	var target_path := path_override if not path_override.is_empty() else save_path
	var file := FileAccess.open(target_path, FileAccess.WRITE)
	if file == null:
		var open_error := FileAccess.get_open_error()
		profile_save_failed.emit(open_error)
		return open_error
	file.store_string(JSON.stringify(_create_snapshot()))
	file.close()
	profile_saved.emit()
	return OK

func load_profile(path_override: String = "") -> bool:
	var target_path := path_override if not path_override.is_empty() else save_path
	if not FileAccess.file_exists(target_path):
		return false
	var file := FileAccess.open(target_path, FileAccess.READ)
	if file == null:
		return false
	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	file.close()
	if parse_error != OK:
		return false
	var parsed: Variant = json.data
	if not parsed is Dictionary or not _apply_snapshot(parsed as Dictionary):
		return false
	profile_loaded.emit()
	return true

func _create_snapshot() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"level": level,
		"experience": experience,
		"currency": currency,
		"weapon_levels": _stringify_level_dictionary(weapon_levels),
		"pet_skill_levels": _stringify_level_dictionary(pet_skill_levels),
	}

func _apply_snapshot(snapshot: Dictionary) -> bool:
	if int(snapshot.get("version", -1)) != SAVE_VERSION:
		return false
	if not snapshot.has("level") or not snapshot.has("experience") or not snapshot.has("currency"):
		return false
	if not snapshot.get("weapon_levels") is Dictionary or not snapshot.get("pet_skill_levels") is Dictionary:
		return false

	var loaded_level := int(snapshot.get("level", 0))
	var loaded_experience := int(snapshot.get("experience", -1))
	var loaded_currency := int(snapshot.get("currency", -1))
	if loaded_level < 1 or loaded_level > 999 or loaded_experience < 0 or loaded_currency < 0:
		return false

	var loaded_weapon_levels := _parse_level_dictionary(snapshot.get("weapon_levels") as Dictionary)
	var loaded_pet_skill_levels := _parse_level_dictionary(snapshot.get("pet_skill_levels") as Dictionary)
	loaded_weapon_levels[STARTER_WEAPON.weapon_id] = maxi(1, int(loaded_weapon_levels.get(STARTER_WEAPON.weapon_id, 1)))
	loaded_pet_skill_levels[ENERGY_BOLT.skill_id] = maxi(1, int(loaded_pet_skill_levels.get(ENERGY_BOLT.skill_id, 1)))

	level = loaded_level
	experience = loaded_experience
	currency = loaded_currency
	weapon_levels = loaded_weapon_levels
	pet_skill_levels = loaded_pet_skill_levels
	upgrades_changed.emit()
	_emit_progress()
	return true

func _stringify_level_dictionary(levels: Dictionary) -> Dictionary:
	var serialized: Dictionary = {}
	for item_id in levels:
		serialized[String(item_id)] = int(levels[item_id])
	return serialized

func _parse_level_dictionary(serialized: Dictionary) -> Dictionary:
	var levels: Dictionary = {}
	for item_id in serialized:
		var item_level := int(serialized[item_id])
		if item_level > 0 and item_level <= 999:
			levels[StringName(String(item_id))] = item_level
	return levels

func _emit_progress() -> void:
	progress_changed.emit(level, experience, experience_required_for_next_level(), currency)
