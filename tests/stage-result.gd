extends SceneTree

var failures: Array[String] = []
var retry_seen: bool = false
var map_seen: bool = false
var requested_stage: int = 0
var upgrade_purchase_count: int = 0

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
	var progression_scene := load("res://game/progression/run_progression.tscn") as PackedScene
	var progression := progression_scene.instantiate() as RunProgression
	root.add_child(progression)
	await process_frame
	result.retry_requested.connect(_on_retry_requested)
	result.map_requested.connect(_on_map_requested)
	result.next_stage_requested.connect(_on_next_stage_requested)
	result.upgrade_purchased.connect(_on_upgrade_purchased)

	_check(not result.visible, "Stage result starts hidden")
	_check(result.get_node("Overlay/ResultPanel") is NinePatchRect, "Result panel is ready for NinePatch production art")
	_check(result.next_stage_card is TextureButton, "Next-stage card is ready for texture states")
	_check(result.get_node("Overlay/ResultPanel/WeaponUpgradePanel") is NinePatchRect, "Weapon shop card is ready for NinePatch production art")
	_check(result.get_node("Overlay/ResultPanel/PetUpgradePanel") is NinePatchRect, "Pet shop card is ready for NinePatch production art")
	progression.award_rewards(270, 180)
	progression.complete_stage(1)
	result.configure_progression(progression)
	result.show_stage_clear(270, 180, 3, 1, true)
	_check(result.visible, "Stage result becomes visible after stage clear")
	_check("XP +270" in result.reward_label.text and "GEARS +180" in result.reward_label.text, "Result summarizes earned rewards")
	_check("PLAYER LEVEL  3" in result.level_label.text, "Result shows the reached player level")
	_check(not result.next_stage_card.disabled, "Available Stage 2 card becomes interactive")
	_check("STAGE 2" in result.stage_label.text and "AVAILABLE" in result.status_label.text, "Next-stage card reports the playable hospital route")
	_check("AVAILABLE GEARS  180" in result.shop_currency_label.text, "Upgrade shop shows spendable Stage 1 currency")
	_check("LEVEL 1 / 5" in result.weapon_upgrade_label.text and not result.weapon_upgrade_button.disabled, "Affordable weapon upgrade is available")
	_check("LEVEL 1 / 5" in result.pet_upgrade_label.text and not result.pet_upgrade_button.disabled, "Affordable pet upgrade is available")
	result._on_weapon_upgrade_pressed()
	_check(progression.get_weapon_level(&"starter_pistol") == 2 and progression.currency == 135, "Weapon shop button buys the configured upgrade")
	_check("LEVEL 2 / 5" in result.weapon_upgrade_label.text and "AVAILABLE GEARS  135" in result.shop_currency_label.text, "Weapon purchase refreshes shop values")
	result._on_pet_upgrade_pressed()
	_check(progression.get_pet_skill_level(&"energy_bolt") == 2 and progression.currency == 100, "Pet shop button buys the configured upgrade")
	_check("LEVEL 2 / 5" in result.pet_upgrade_label.text and "AVAILABLE GEARS  100" in result.shop_currency_label.text, "Pet purchase refreshes shop values")
	_check(upgrade_purchase_count == 2, "Successful shop purchases request profile persistence")
	result._on_retry_pressed()
	_check(retry_seen, "Replay control emits a retry request")
	result._on_map_pressed()
	_check(map_seen, "Campaign-map control emits a map request")
	result._on_next_stage_pressed()
	_check(requested_stage == 2, "Next-stage card requests Stage 2")

	result.queue_free()
	progression.queue_free()
	_finish()

func _on_retry_requested() -> void:
	retry_seen = true

func _on_map_requested() -> void:
	map_seen = true

func _on_next_stage_requested(stage_number: int) -> void:
	requested_stage = stage_number

func _on_upgrade_purchased() -> void:
	upgrade_purchase_count += 1

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
