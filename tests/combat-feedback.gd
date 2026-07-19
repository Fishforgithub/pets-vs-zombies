extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var bullet_scene := load("res://game/projectiles/bullet.tscn") as PackedScene
	var zombie_scene := load("res://game/enemies/zombie.tscn") as PackedScene
	var effect_scene := load("res://game/vfx/combat_hit_effect.tscn") as PackedScene
	_check(bullet_scene != null and zombie_scene != null and effect_scene != null, "Combat feedback scenes load")
	if bullet_scene == null or zombie_scene == null or effect_scene == null:
		_finish()
		return

	var host := Node2D.new()
	root.add_child(host)
	current_scene = host
	var zombie := zombie_scene.instantiate() as ZombieEnemy
	host.add_child(zombie)
	var bullet := bullet_scene.instantiate() as GameBullet
	host.add_child(bullet)
	bullet.global_position = Vector2(80.0, 40.0)
	bullet.configure(Vector2.RIGHT, &"enemies", 20, Color("ffe066"), 1)
	var health_before := zombie.health
	bullet._try_damage(zombie)
	_check(bullet.hit_consumed, "Player bullet consumes its hit once")
	_check(zombie.health == health_before - 20, "Player bullet applies configured damage")
	_check(is_equal_approx(zombie.hit_flash, 0.18), "Enemy uses the stronger hit-flash duration")
	var bullet_effect := _find_effect(host, 1)
	_check(bullet_effect != null, "Player bullet spawns the authored impact effect")
	if bullet_effect != null:
		_check(bullet_effect.global_position == bullet.global_position, "Impact effect appears at the collision position")
		_check(bullet_effect.region_rect == Rect2(256.0, 0.0, 256.0, 256.0), "Player impact selects combat-effect cell 1")

	var pet_bullet := bullet_scene.instantiate() as GameBullet
	host.add_child(pet_bullet)
	pet_bullet.global_position = Vector2(100.0, 45.0)
	pet_bullet.configure(Vector2(1.0, -0.2), &"enemies", 8, Color("74c0fc"), 2)
	pet_bullet._try_damage(zombie)
	var pet_effect := _find_effect(host, 2)
	_check(pet_effect != null, "Pet projectile spawns the authored energy-hit effect")
	if pet_effect != null:
		_check(pet_effect.region_rect == Rect2(512.0, 0.0, 256.0, 256.0), "Pet impact selects combat-effect cell 2")

	var standalone_effect := effect_scene.instantiate() as CombatHitEffect
	host.add_child(standalone_effect)
	standalone_effect.configure(1, 0.1)
	_check(standalone_effect.get_child_count() == 0, "Combat impact remains presentation-only without collision")
	standalone_effect._process(0.1)
	_check(standalone_effect.is_queued_for_deletion(), "Combat impact removes itself after its flash")

	host.queue_free()
	_finish()

func _find_effect(host: Node, effect_index: int) -> CombatHitEffect:
	for child in host.get_children():
		if child is CombatHitEffect and (child as CombatHitEffect).effect_index == effect_index:
			return child as CombatHitEffect
	return null

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)

func _finish() -> void:
	if failures.is_empty():
		print("Combat feedback checks passed.")
		quit(0)
	else:
		printerr("Combat feedback checks failed: ", ", ".join(failures))
		quit(1)
