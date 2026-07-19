class_name StageResultScreen
extends CanvasLayer

signal retry_requested
signal map_requested
signal upgrade_purchased

const STARTER_WEAPON: WeaponData = preload("res://game/data/weapons/starter_pistol.tres")
const ENERGY_BOLT: PetSkillData = preload("res://game/data/pet_skills/energy_bolt.tres")

@onready var title_label: Label = $Overlay/ResultPanel/TitleLabel
@onready var reward_label: Label = $Overlay/ResultPanel/RewardLabel
@onready var level_label: Label = $Overlay/ResultPanel/LevelLabel
@onready var weapon_upgrade_label: Label = $Overlay/ResultPanel/WeaponUpgradePanel/UpgradeLabel
@onready var weapon_upgrade_button: Button = $Overlay/ResultPanel/WeaponUpgradePanel/UpgradeButton
@onready var pet_upgrade_label: Label = $Overlay/ResultPanel/PetUpgradePanel/UpgradeLabel
@onready var pet_upgrade_button: Button = $Overlay/ResultPanel/PetUpgradePanel/UpgradeButton
@onready var shop_currency_label: Label = $Overlay/ResultPanel/ShopCurrencyLabel
@onready var next_stage_card: TextureButton = $Overlay/ResultPanel/NextStageCard
@onready var stage_label: Label = $Overlay/ResultPanel/NextStageCard/StageLabel
@onready var status_label: Label = $Overlay/ResultPanel/NextStageCard/StatusLabel
@onready var retry_button: Button = $Overlay/ResultPanel/RetryButton
@onready var map_button: Button = $Overlay/ResultPanel/MapButton

var progression: RunProgression

func _ready() -> void:
	retry_button.pressed.connect(_on_retry_pressed)
	map_button.pressed.connect(_on_map_pressed)
	weapon_upgrade_button.pressed.connect(_on_weapon_upgrade_pressed)
	pet_upgrade_button.pressed.connect(_on_pet_upgrade_pressed)
	visible = false
	_refresh_shop()

func configure_progression(run_progression: RunProgression) -> void:
	if is_instance_valid(progression) and progression.progress_changed.is_connected(_on_progress_changed):
		progression.progress_changed.disconnect(_on_progress_changed)
	progression = run_progression
	if is_instance_valid(progression) and not progression.progress_changed.is_connected(_on_progress_changed):
		progression.progress_changed.connect(_on_progress_changed)
	_refresh_shop()

func show_stage_clear(experience_earned: int, currency_earned: int, player_level: int) -> void:
	title_label.text = "STAGE 1 CLEAR"
	reward_label.text = "XP +%d     GEARS +%d" % [experience_earned, currency_earned]
	level_label.text = "PLAYER LEVEL  %d" % player_level
	stage_label.text = "STAGE 2\nHOSPITAL CORRIDOR"
	status_label.text = "UNLOCKED — UNDER CONSTRUCTION" if is_instance_valid(progression) and progression.is_stage_unlocked(2) else "LOCKED — CLEAR STAGE 1"
	next_stage_card.disabled = true
	visible = true
	_refresh_shop()
	if not weapon_upgrade_button.disabled:
		weapon_upgrade_button.grab_focus()
	elif not pet_upgrade_button.disabled:
		pet_upgrade_button.grab_focus()
	else:
		retry_button.grab_focus()

func _refresh_shop() -> void:
	if not is_instance_valid(progression):
		shop_currency_label.text = "GEARS  —"
		weapon_upgrade_label.text = "STARTER PISTOL\nPROGRESSION UNAVAILABLE"
		pet_upgrade_label.text = "ENERGY BOLT\nPROGRESSION UNAVAILABLE"
		weapon_upgrade_button.text = "UNAVAILABLE"
		pet_upgrade_button.text = "UNAVAILABLE"
		weapon_upgrade_button.disabled = true
		pet_upgrade_button.disabled = true
		return

	shop_currency_label.text = "AVAILABLE GEARS  %d" % progression.currency
	_refresh_weapon_upgrade()
	_refresh_pet_upgrade()

func _refresh_weapon_upgrade() -> void:
	var current_level := progression.get_weapon_level(STARTER_WEAPON.weapon_id)
	var cost := STARTER_WEAPON.upgrade_cost(current_level)
	if cost < 0:
		weapon_upgrade_label.text = "%s\nLEVEL %d / %d\nDAMAGE  %d\nMAX LEVEL" % [STARTER_WEAPON.display_name.to_upper(), current_level, STARTER_WEAPON.max_level, STARTER_WEAPON.damage_at(current_level)]
		weapon_upgrade_button.text = "MAXED"
		weapon_upgrade_button.disabled = true
		return
	weapon_upgrade_label.text = "%s\nLEVEL %d / %d\nDAMAGE  %d → %d" % [STARTER_WEAPON.display_name.to_upper(), current_level, STARTER_WEAPON.max_level, STARTER_WEAPON.damage_at(current_level), STARTER_WEAPON.damage_at(current_level + 1)]
	weapon_upgrade_button.text = "UPGRADE  %d" % cost
	weapon_upgrade_button.disabled = progression.currency < cost

func _refresh_pet_upgrade() -> void:
	var current_level := progression.get_pet_skill_level(ENERGY_BOLT.skill_id)
	var cost := ENERGY_BOLT.upgrade_cost(current_level)
	if cost < 0:
		pet_upgrade_label.text = "%s\nLEVEL %d / %d\nDAMAGE  %d\nMAX LEVEL" % [ENERGY_BOLT.display_name.to_upper(), current_level, ENERGY_BOLT.max_level, ENERGY_BOLT.damage_at(current_level)]
		pet_upgrade_button.text = "MAXED"
		pet_upgrade_button.disabled = true
		return
	pet_upgrade_label.text = "%s\nLEVEL %d / %d\nDAMAGE  %d → %d\nCOOLDOWN  %.2fs" % [ENERGY_BOLT.display_name.to_upper(), current_level, ENERGY_BOLT.max_level, ENERGY_BOLT.damage_at(current_level), ENERGY_BOLT.damage_at(current_level + 1), ENERGY_BOLT.cooldown_at(current_level + 1)]
	pet_upgrade_button.text = "UPGRADE  %d" % cost
	pet_upgrade_button.disabled = progression.currency < cost

func _on_weapon_upgrade_pressed() -> void:
	if is_instance_valid(progression) and progression.try_upgrade_weapon(STARTER_WEAPON):
		upgrade_purchased.emit()
	_refresh_shop()

func _on_pet_upgrade_pressed() -> void:
	if is_instance_valid(progression) and progression.try_upgrade_pet_skill(ENERGY_BOLT):
		upgrade_purchased.emit()
	_refresh_shop()

func _on_progress_changed(_level: int, _experience: int, _experience_required: int, _currency: int) -> void:
	_refresh_shop()

func _on_retry_pressed() -> void:
	retry_requested.emit()

func _on_map_pressed() -> void:
	map_requested.emit()
