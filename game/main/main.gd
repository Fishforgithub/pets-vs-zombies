class_name CampaignMap
extends Control

const STAGE_1_SCENE_PATH := "res://game/stages/stage1.tscn"
const STAGE_2_SCENE_PATH := "res://game/stages/stage2.tscn"

@onready var progression: RunProgression = $Progression
@onready var profile_label: Label = $ProfileLabel
@onready var stage_1_card: TextureButton = $Stage1Card
@onready var stage_1_status: Label = $Stage1Card/StatusLabel
@onready var stage_2_card: TextureButton = $Stage2Card
@onready var stage_2_status: Label = $Stage2Card/StatusLabel
@onready var route_status: Label = $RouteStatus

func _ready() -> void:
	progression.load_profile()
	stage_1_card.pressed.connect(_on_stage_1_pressed)
	stage_2_card.pressed.connect(_on_stage_2_pressed)
	progression.progress_changed.connect(_on_profile_changed)
	progression.campaign_changed.connect(_refresh_route)
	_refresh_route()
	stage_1_card.grab_focus()

func _refresh_route() -> void:
	profile_label.text = "PLAYER LEVEL  %d     GEARS  %d" % [progression.level, progression.currency]
	stage_1_status.text = "CLEARED  •  REPLAY" if progression.is_stage_completed(1) else "AVAILABLE  •  5 WAVES + BOSS"
	var stage_2_unlocked := progression.is_stage_unlocked(2)
	var stage_2_available := ResourceLoader.exists(STAGE_2_SCENE_PATH)
	stage_2_card.disabled = not stage_2_unlocked or not stage_2_available
	if not stage_2_unlocked:
		stage_2_status.text = "LOCKED  •  CLEAR STAGE 1"
		route_status.text = "Defeat the Undead Foreman to open the hospital route."
	elif not stage_2_available:
		stage_2_status.text = "UNLOCKED  •  UNDER CONSTRUCTION"
		route_status.text = "Stage 2 is unlocked and will become playable when its scene is complete."
	else:
		stage_2_status.text = "AVAILABLE  •  ENTER"
		route_status.text = "Choose any unlocked stage. Progress and upgrades carry between stages."

func _on_stage_1_pressed() -> void:
	get_tree().change_scene_to_file(STAGE_1_SCENE_PATH)

func _on_stage_2_pressed() -> void:
	if progression.is_stage_unlocked(2) and ResourceLoader.exists(STAGE_2_SCENE_PATH):
		get_tree().change_scene_to_file(STAGE_2_SCENE_PATH)

func _on_profile_changed(_level: int, _experience: int, _required: int, _currency: int) -> void:
	_refresh_route()
