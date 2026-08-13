class_name CampaignMap
extends Control

const STAGE_1_SCENE_PATH := "res://game/stages/stage1.tscn"
const STAGE_2_SCENE_PATH := "res://game/stages/stage2.tscn"
const CARD_IDLE_COLOR := Color(0.82, 0.88, 0.96, 1.0)
const CARD_SELECTED_COLOR := Color(1.0, 1.0, 1.0, 1.0)
const CARD_LOCKED_COLOR := Color(0.52, 0.58, 0.66, 1.0)

@onready var progression: RunProgression = $Progression
@onready var profile_label: Label = $ProfileLabel
@onready var stage_1_card: TextureButton = $Stage1Card
@onready var stage_1_status: Label = $Stage1Card/StatusLabel
@onready var stage_2_card: TextureButton = $Stage2Card
@onready var stage_2_status: Label = $Stage2Card/StatusLabel
@onready var route_status: Label = $RouteStatus
@onready var controls_label: Label = $Controls

var selected_stage_number: int = 1

func _ready() -> void:
	progression.load_profile()
	stage_1_card.pressed.connect(_on_stage_1_pressed)
	stage_2_card.pressed.connect(_on_stage_2_pressed)
	stage_1_card.focus_entered.connect(_on_stage_card_focused.bind(1))
	stage_2_card.focus_entered.connect(_on_stage_card_focused.bind(2))
	stage_1_card.mouse_entered.connect(_on_route_card_hovered.bind(stage_1_card))
	stage_2_card.mouse_entered.connect(_on_route_card_hovered.bind(stage_2_card))
	progression.progress_changed.connect(_on_profile_changed)
	progression.campaign_changed.connect(_refresh_route)
	_refresh_route()
	call_deferred("_focus_selected_stage")

func _unhandled_key_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	if key_event.keycode == KEY_TAB:
		_focus_next_available_stage()
		get_viewport().set_input_as_handled()
	elif key_event.keycode == KEY_ENTER or key_event.keycode == KEY_KP_ENTER or key_event.keycode == KEY_SPACE:
		_activate_selected_stage()
		get_viewport().set_input_as_handled()

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
	elif progression.is_stage_completed(2):
		stage_2_status.text = "CLEARED  •  REPLAY"
		route_status.text = "Both available stages are cleared. Replay either route to earn more upgrades."
	else:
		stage_2_status.text = "AVAILABLE  •  ENTER"
		route_status.text = "Choose any unlocked stage. Progress and upgrades carry between stages."
	if stage_2_card.disabled and selected_stage_number == 2:
		selected_stage_number = 1
	_refresh_route_focus()

func _refresh_route_focus() -> void:
	stage_1_card.focus_mode = Control.FOCUS_ALL
	stage_2_card.focus_mode = Control.FOCUS_ALL if not stage_2_card.disabled else Control.FOCUS_NONE
	stage_1_card.self_modulate = CARD_SELECTED_COLOR if selected_stage_number == 1 else CARD_IDLE_COLOR
	if stage_2_card.disabled:
		stage_2_card.self_modulate = CARD_LOCKED_COLOR
	else:
		stage_2_card.self_modulate = CARD_SELECTED_COLOR if selected_stage_number == 2 else CARD_IDLE_COLOR
	var selected_label := "STAGE %d" % selected_stage_number
	controls_label.text = "SELECTED: %s   •   TAB: SWITCH ROUTE   •   ENTER / SPACE: START" % selected_label

func _on_stage_card_focused(stage_number: int) -> void:
	if stage_number == 2 and stage_2_card.disabled:
		return
	selected_stage_number = stage_number
	_refresh_route_focus()

func _on_route_card_hovered(card: TextureButton) -> void:
	if not card.disabled:
		card.grab_focus()

func _focus_selected_stage() -> void:
	if selected_stage_number == 2 and not stage_2_card.disabled:
		stage_2_card.grab_focus()
	else:
		selected_stage_number = 1
		stage_1_card.grab_focus()
	_refresh_route_focus()

func _focus_next_available_stage() -> void:
	if not stage_2_card.disabled:
		selected_stage_number = 2 if selected_stage_number == 1 else 1
	_focus_selected_stage()

func _activate_selected_stage() -> void:
	if selected_stage_number == 2 and not stage_2_card.disabled:
		_on_stage_2_pressed()
	else:
		_on_stage_1_pressed()

func _on_stage_1_pressed() -> void:
	get_tree().change_scene_to_file(STAGE_1_SCENE_PATH)

func _on_stage_2_pressed() -> void:
	if progression.is_stage_unlocked(2) and ResourceLoader.exists(STAGE_2_SCENE_PATH):
		get_tree().change_scene_to_file(STAGE_2_SCENE_PATH)

func _on_profile_changed(_level: int, _experience: int, _required: int, _currency: int) -> void:
	_refresh_route()
