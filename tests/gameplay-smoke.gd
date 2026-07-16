extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var main_scene := load("res://game/main/main.tscn") as PackedScene
	_check(main_scene != null, "Main scene loads")
	if main_scene == null:
		_finish()
		return

	var main := main_scene.instantiate()
	main.persistence_enabled = false
	var test_director := main.get_node("WaveDirector") as WaveDirector
	test_director.wave_configs = _fast_test_waves()
	test_director.inter_wave_delay = 0.0
	root.add_child(main)
	current_scene = main
	await _wait_physics_frames(3)

	var player := main.player as PlayerGirl
	var pet := main.pet as PetCompanion
	_check(player.is_on_floor(), "Player starts on the stage floor")
	_check(main.production_background_active, "Production city background loads")
	_check(main.ground_tiles_texture != null, "Production ground tiles load")
	_check(main.get_node_or_null("ProductionBackground") is Parallax2D, "Production parallax layer is active")
	_check(main.wave_director.get_total_wave_count() == 5, "Stage runs five configured waves")
	_check(main.wave_director.current_wave_index == 0, "Stage begins on wave one")
	_check("WAVE  1 / 5" in main.hud.wave_label.text, "HUD shows the active wave")

	var start_x := player.global_position.x
	Input.action_press("move_right")
	await _wait_physics_frames(6)
	Input.action_release("move_right")
	_check(player.global_position.x > start_x, "Movement input moves the player")

	Input.action_press("jump")
	await _wait_physics_frames(2)
	Input.action_release("jump")
	_check(player.velocity.y < 0.0, "Jump input launches the player upward")
	await _wait_until_landed(player, 120)
	_check(player.is_on_floor(), "Player lands after jumping")

	var ammo_before := player.ammo
	Input.action_press("fire")
	await physics_frame
	Input.action_release("fire")
	_check(player.ammo == ammo_before - 1, "Fire input consumes ammunition")

	player.global_position += Vector2(300.0, 0.0)
	var follow_target := player.global_position + pet.follow_offset
	var pet_distance_before := pet.global_position.distance_to(follow_target)
	await _wait_physics_frames(10)
	var pet_distance_after := pet.global_position.distance_to(follow_target)
	_check(pet_distance_after < pet_distance_before, "Pet moves toward its follow position")

	var active_enemies: Array[Node] = main.enemies.get_children()
	_check(not active_enemies.is_empty(), "Wave director spawns the first courier zombie")
	if not active_enemies.is_empty():
		var target := active_enemies[0] as ZombieEnemy
		target.global_position = pet.global_position + Vector2(100.0, 0.0)
		pet.attack_cooldown = 0.0
		var bullets_before := _count_bullets(main)
		await physics_frame
		_check(_count_bullets(main) > bullets_before, "Pet auto-attack creates a projectile")

	var health_before := player.health
	player.take_damage(10)
	_check(player.health == health_before - 10, "Player damage reduces health")

	for _iteration in range(100):
		for enemy_node in main.enemies.get_children():
			var enemy := enemy_node as ZombieEnemy
			if is_instance_valid(enemy) and not enemy.is_dead:
				enemy.take_damage(enemy.health)
		await process_frame
		if main.wave_director.finished:
			break
	_check(main.defeated_count == 5, "Five fast test waves each award one defeat")
	_check(main.wave_director.finished, "Defeating all five waves completes the director")
	_check(player.progression.level == 2 and player.progression.experience == 10, "Five courier rewards level the player once with XP overflow")
	_check(player.progression.currency == 60, "Five courier rewards grant spendable currency")
	_check(is_instance_valid(main.active_boss), "Foreman enters after wave five")
	_check(main.hud.boss_panel.visible, "Boss entrance shows the boss health bar")
	_check(main.hud.boss_frame.texture != null and main.hud.boss_frame.texture.get_size() == Vector2(640.0, 96.0), "Boss HUD uses the production health frame")
	if is_instance_valid(main.active_boss):
		main.active_boss.defeat_delay = 0.0
		main.active_boss.take_damage(main.active_boss.health)
		await process_frame
		await physics_frame
	_check(main.finished, "Defeating the boss marks the run finished")
	_check(player.progression.level == 3 and player.progression.currency == 180, "Boss rewards grant XP, currency, and another level")
	_check("LV 3" in main.hud.progression_label.text, "HUD reflects earned progression")
	_check(main.stage_result.visible, "Stage completion shows the result screen")
	_check("XP +270" in main.stage_result.reward_label.text and "GEARS +180" in main.stage_result.reward_label.text, "Result screen reports all Stage 1 rewards")
	_check(main.stage_result.next_stage_card.disabled, "Stage 2 card remains locked as a placeholder")
	_check("STAGE 1 CLEAR" in main.stage_result.title_label.text, "Stage completion shows the clear title")
	_check(main.stage_result.progression == player.progression, "Stage result shop uses the active run progression")
	_check("AVAILABLE GEARS  180" in main.stage_result.shop_currency_label.text, "Stage result shop exposes earned boss currency")
	_check(not main.stage_result.weapon_upgrade_button.disabled and not main.stage_result.pet_upgrade_button.disabled, "Earned Stage 1 rewards can buy both upgrade types")

	main.queue_free()
	await process_frame

	var defeat_main := main_scene.instantiate()
	defeat_main.persistence_enabled = false
	root.add_child(defeat_main)
	current_scene = defeat_main
	await _wait_physics_frames(2)
	var defeat_player := defeat_main.player as PlayerGirl
	defeat_player.take_damage(defeat_player.max_health)
	_check(defeat_player.is_dead, "Lethal damage kills the player")
	_check(defeat_main.finished, "Player death finishes the run")
	_check("TRY AGAIN" in defeat_main.hud.message_label.text, "Player death shows the defeat message")

	defeat_main.queue_free()
	_finish()

func _fast_test_waves() -> Array[Dictionary]:
	return [
		{"enemy_count": 1, "spawn_interval": 0.0, "max_alive": 1, "spawn_sides": [1]},
		{"enemy_count": 1, "spawn_interval": 0.0, "max_alive": 1, "spawn_sides": [1]},
		{"enemy_count": 1, "spawn_interval": 0.0, "max_alive": 1, "spawn_sides": [-1]},
		{"enemy_count": 1, "spawn_interval": 0.0, "max_alive": 1, "spawn_sides": [1]},
		{"enemy_count": 1, "spawn_interval": 0.0, "max_alive": 1, "spawn_sides": [-1]},
	]

func _wait_physics_frames(count: int) -> void:
	for _index in range(count):
		await physics_frame

func _wait_until_landed(player: PlayerGirl, maximum_frames: int) -> void:
	for _index in range(maximum_frames):
		await physics_frame
		if player.is_on_floor() and player.velocity.y >= 0.0:
			return

func _count_bullets(main: Node) -> int:
	var count := 0
	for child in main.get_children():
		if child is GameBullet:
			count += 1
	return count

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)

func _finish() -> void:
	Input.action_release("move_right")
	Input.action_release("jump")
	Input.action_release("fire")
	if failures.is_empty():
		print("Gameplay smoke checks passed.")
		quit(0)
	else:
		printerr("Gameplay smoke checks failed: ", ", ".join(failures))
		quit(1)
