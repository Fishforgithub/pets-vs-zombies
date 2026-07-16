class_name StageResultScreen
extends CanvasLayer

signal retry_requested

@onready var title_label: Label = $Overlay/ResultPanel/TitleLabel
@onready var reward_label: Label = $Overlay/ResultPanel/RewardLabel
@onready var level_label: Label = $Overlay/ResultPanel/LevelLabel
@onready var next_stage_card: TextureButton = $Overlay/ResultPanel/NextStageCard
@onready var stage_label: Label = $Overlay/ResultPanel/NextStageCard/StageLabel
@onready var status_label: Label = $Overlay/ResultPanel/NextStageCard/StatusLabel
@onready var retry_button: Button = $Overlay/ResultPanel/RetryButton

func _ready() -> void:
	retry_button.pressed.connect(_on_retry_pressed)
	visible = false

func show_stage_clear(experience_earned: int, currency_earned: int, player_level: int) -> void:
	title_label.text = "STAGE 1 CLEAR"
	reward_label.text = "XP +%d     GEARS +%d" % [experience_earned, currency_earned]
	level_label.text = "PLAYER LEVEL  %d" % player_level
	stage_label.text = "STAGE 2\nSUBURBAN NIGHT"
	status_label.text = "LOCKED — COMING SOON"
	next_stage_card.disabled = true
	visible = true
	retry_button.grab_focus()

func _on_retry_pressed() -> void:
	retry_requested.emit()
