extends SceneTree

const TEST_SAVE_PATH: String = "user://campaign_profile_test.json"

var failures: Array[String] = []
var progress_signal_count: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed_scene := load("res://game/progression/run_progression.tscn") as PackedScene
	_check(packed_scene != null, "Run progression scene loads")
	if packed_scene == null:
		_finish()
		return
	var progression := packed_scene.instantiate() as RunProgression
	root.add_child(progression)
	progression.progress_changed.connect(_on_progress_changed)
	await process_frame

	_check(progression.level == 1, "Progression starts at level one")
	_check(progression.experience_required_for_next_level() == 80, "Level one requires 80 XP")
	_check(progression.currency == 0, "Progression starts without currency")
	_check(progression.get_weapon_level(&"starter_pistol") == 1, "Starter pistol is owned at level one")
	_check(progression.get_pet_skill_level(&"energy_bolt") == 1, "Energy Bolt is owned at level one")
	_check(progression.is_stage_unlocked(1) and not progression.is_stage_unlocked(2), "A new campaign starts with only Stage 1 unlocked")

	progression.award_rewards(50, 20)
	_check(progression.level == 1 and progression.experience == 50, "Rewards add experience without premature level-up")
	_check(progression.currency == 20, "Rewards add currency")
	progression.award_rewards(40, 30)
	_check(progression.level == 2 and progression.experience == 10, "Overflow XP carries into the next level")
	_check(progression.experience_required_for_next_level() == 125, "XP requirement grows by level")

	var weapon := RunProgression.STARTER_WEAPON
	_check(weapon.damage_at(1) == 25 and weapon.damage_at(2) == 31, "Weapon damage scales from data")
	_check(progression.try_upgrade_weapon(weapon), "Currency purchases a starter pistol upgrade")
	_check(progression.get_weapon_level(weapon.weapon_id) == 2, "Weapon upgrade level is recorded")
	_check(progression.currency == 5, "Weapon upgrade deducts its configured cost")
	_check(not progression.try_upgrade_weapon(weapon), "Weapon upgrade fails when currency is insufficient")

	progression.award_rewards(0, 100)
	var skill := RunProgression.ENERGY_BOLT
	_check(progression.try_upgrade_pet_skill(skill), "Currency purchases a pet-skill upgrade")
	_check(progression.get_pet_skill_level(skill.skill_id) == 2, "Pet-skill upgrade level is recorded")
	_check(skill.damage_at(2) > skill.damage_at(1), "Pet-skill damage improves by level")
	_check(skill.cooldown_at(2) < skill.cooldown_at(1), "Pet-skill cooldown improves by level")

	var locked_weapon := WeaponData.new()
	locked_weapon.weapon_id = &"test_rifle"
	locked_weapon.unlock_level = 3
	locked_weapon.purchase_price = 10
	_check(not progression.try_purchase_weapon(locked_weapon), "Locked weapon cannot be bought below its unlock level")
	progression.award_rewards(250, 0)
	_check(progression.level == 3, "Multiple rewards can reach the weapon unlock level")
	_check(progression.try_purchase_weapon(locked_weapon), "Unlocked weapon can be bought with earned currency")
	_check(progression.get_weapon_level(&"test_rifle") == 1, "Purchased weapon enters the inventory")
	_check(progress_signal_count > 0, "Progression emits UI update signals")
	progression.complete_stage(1)
	_check(progression.is_stage_completed(1), "Clearing Stage 1 records campaign completion")
	_check(progression.is_stage_unlocked(2), "Clearing Stage 1 unlocks the next route card")

	_remove_test_save()
	_check(progression.save_profile(TEST_SAVE_PATH) == OK, "Campaign profile saves as versioned JSON")
	_check(FileAccess.file_exists(TEST_SAVE_PATH), "Campaign save file is created")
	var restored := packed_scene.instantiate() as RunProgression
	root.add_child(restored)
	await process_frame
	_check(restored.load_profile(TEST_SAVE_PATH), "Campaign profile loads successfully")
	_check(restored.level == progression.level and restored.experience == progression.experience and restored.currency == progression.currency, "Campaign level, XP, and currency survive reload")
	_check(restored.weapon_levels == progression.weapon_levels, "Owned weapon levels survive reload")
	_check(restored.pet_skill_levels == progression.pet_skill_levels, "Pet-skill levels survive reload")
	_check(restored.completed_stages == [1] and restored.highest_unlocked_stage == 2, "Stage completion and unlock state survive reload")

	var legacy := packed_scene.instantiate() as RunProgression
	root.add_child(legacy)
	await process_frame
	var legacy_snapshot := {
		"version": 1,
		"level": 2,
		"experience": 10,
		"currency": 20,
		"weapon_levels": {"starter_pistol": 1},
		"pet_skill_levels": {"energy_bolt": 1},
	}
	_check(legacy._apply_snapshot(legacy_snapshot), "Version 1 profiles migrate without losing progression")
	_check(legacy.highest_unlocked_stage == 1 and legacy.completed_stages.is_empty(), "Legacy profiles receive safe Stage 1 campaign defaults")

	var currency_before_corruption := restored.currency
	var corrupt_file := FileAccess.open(TEST_SAVE_PATH, FileAccess.WRITE)
	corrupt_file.store_string("{not valid json")
	corrupt_file.close()
	_check(not restored.load_profile(TEST_SAVE_PATH), "Corrupt campaign data is rejected")
	_check(restored.currency == currency_before_corruption, "Rejected save data does not overwrite the active profile")
	_remove_test_save()

	progression.queue_free()
	restored.queue_free()
	legacy.queue_free()
	_finish()

func _remove_test_save() -> void:
	var absolute_path := ProjectSettings.globalize_path(TEST_SAVE_PATH)
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(absolute_path)

func _on_progress_changed(_level: int, _experience: int, _required: int, _currency: int) -> void:
	progress_signal_count += 1

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)

func _finish() -> void:
	if failures.is_empty():
		print("Progression checks passed.")
		quit(0)
	else:
		printerr("Progression checks failed: ", ", ".join(failures))
		quit(1)
