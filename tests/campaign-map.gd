extends SceneTree

const TEST_SAVE_PATH := "user://campaign_map_test.json"

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_remove_test_save()
	var packed_scene := load("res://game/main/main.tscn") as PackedScene
	_check(packed_scene != null, "Campaign map scene loads")
	if packed_scene == null:
		_finish()
		return

	var campaign_map := packed_scene.instantiate() as CampaignMap
	var progression := campaign_map.get_node("Progression") as RunProgression
	progression.save_path = TEST_SAVE_PATH
	root.add_child(campaign_map)
	current_scene = campaign_map
	await process_frame
	_check(not campaign_map.stage_1_card.disabled, "Stage 1 is selectable for a new profile")
	_check(campaign_map.stage_2_card.disabled, "Stage 2 is locked before Stage 1 clear")
	_check("PLAYER LEVEL  1" in campaign_map.profile_label.text, "Campaign map shows persisted profile summary")
	_check("CLEAR STAGE 1" in campaign_map.stage_2_status.text, "Locked route explains its unlock requirement")
	_check(campaign_map.stage_1_card.focus_mode == Control.FOCUS_ALL, "Stage 1 card accepts keyboard focus")
	_check(campaign_map.selected_stage_number == 1 and "SELECTED: STAGE 1" in campaign_map.controls_label.text, "Campaign map announces the initial selected route")

	progression.complete_stage(1)
	progression.award_rewards(80, 45)
	_check(progression.save_profile() == OK, "Route progress saves from the campaign map model")
	campaign_map._refresh_route()
	_check("CLEARED" in campaign_map.stage_1_status.text, "Cleared Stage 1 remains available for replay")
	_check(not campaign_map.stage_2_card.disabled and "AVAILABLE" in campaign_map.stage_2_status.text, "Unlocked Stage 2 becomes selectable when its gameplay scene exists")
	campaign_map._focus_next_available_stage()
	_check(campaign_map.selected_stage_number == 2 and campaign_map.stage_2_card.has_focus(), "Campaign map can move keyboard focus to an unlocked Stage 2")
	_check("SELECTED: STAGE 2" in campaign_map.controls_label.text, "Campaign map updates its selected-route instruction")
	campaign_map._focus_next_available_stage()
	_check(campaign_map.selected_stage_number == 1 and campaign_map.stage_1_card.has_focus(), "Campaign map loops keyboard focus back to Stage 1")

	campaign_map.queue_free()
	await process_frame
	var restored_map := packed_scene.instantiate() as CampaignMap
	var restored_progression := restored_map.get_node("Progression") as RunProgression
	restored_progression.save_path = TEST_SAVE_PATH
	root.add_child(restored_map)
	current_scene = restored_map
	await process_frame
	_check(restored_progression.is_stage_completed(1), "A later session restores completed stages")
	_check(restored_progression.is_stage_unlocked(2), "A later session restores unlocked route progress")
	_check(not restored_map.stage_2_card.disabled, "A later session can select the restored Stage 2 route")
	_check("LEVEL  2" in restored_map.profile_label.text and "GEARS  45" in restored_map.profile_label.text, "A later session restores level and gears on the route map")

	restored_map.queue_free()
	_remove_test_save()
	_finish()

func _remove_test_save() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)

func _finish() -> void:
	if failures.is_empty():
		print("Campaign map checks passed.")
		quit(0)
	else:
		printerr("Campaign map checks failed: ", ", ".join(failures))
		quit(1)
