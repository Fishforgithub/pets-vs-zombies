extends SceneTree

var failures: Array[String] = []
var retry_seen: bool = false

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed_scene := load("res://game/ui/stage_result.tscn") as PackedScene
	_check(packed_scene != null, "Stage result scene loads")
	if packed_scene == null:
		_finish()
		return
	var result := packed_scene.instantiate() as StageResultScreen
	root.add_child(result)
	await process_frame
	result.retry_requested.connect(_on_retry_requested)

	_check(not result.visible, "Stage result starts hidden")
	_check(result.get_node("Overlay/ResultPanel") is NinePatchRect, "Result panel is ready for NinePatch production art")
	_check(result.next_stage_card is TextureButton, "Next-stage card is ready for texture states")
	result.show_stage_clear(270, 180, 3)
	_check(result.visible, "Stage result becomes visible after stage clear")
	_check("XP +270" in result.reward_label.text and "GEARS +180" in result.reward_label.text, "Result summarizes earned rewards")
	_check("PLAYER LEVEL  3" in result.level_label.text, "Result shows the reached player level")
	_check(result.next_stage_card.disabled, "Unavailable Stage 2 card is locked")
	_check("STAGE 2" in result.stage_label.text and "COMING SOON" in result.status_label.text, "Next-stage placeholder explains availability")
	result._on_retry_pressed()
	_check(retry_seen, "Replay control emits a retry request")

	result.queue_free()
	_finish()

func _on_retry_requested() -> void:
	retry_seen = true

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)

func _finish() -> void:
	if failures.is_empty():
		print("Stage result checks passed.")
		quit(0)
	else:
		printerr("Stage result checks failed: ", ", ".join(failures))
		quit(1)
