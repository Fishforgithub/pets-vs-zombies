extends SceneTree

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

	progression.queue_free()
	_finish()

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
