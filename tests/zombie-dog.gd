extends SceneTree

var failures: Array[String] = []
var defeated_events: int = 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var dog_scene := load("res://game/enemies/stage2/zombie_dog.tscn") as PackedScene
	var player_scene := load("res://game/player/player.tscn") as PackedScene
	_check(dog_scene != null, "Zombie dog scene loads")
	_check(player_scene != null, "Player scene loads for zombie dog targeting")
	if dog_scene == null or player_scene == null:
		_finish()
		return

	var player := player_scene.instantiate() as PlayerGirl
	var dog := dog_scene.instantiate() as ZombieDog
	root.add_child(player)
	root.add_child(dog)
	player.global_position = Vector2(500, 620)
	dog.global_position = Vector2(650, 620)
	dog.target = player
	dog.defeated.connect(_on_dog_defeated)
	await process_frame

	_check(dog is WaveEnemy, "Zombie dog implements the shared wave enemy interface")
	_check(dog.health == dog.max_health, "Zombie dog starts at maximum health")
	_check(dog.experience_reward == 22 and dog.currency_reward == 15, "Zombie dog grants tuned Stage 2 rewards")
	_check(dog.collision_shape.shape is RectangleShape2D, "Zombie dog uses a stable low torso collision")
	_check(dog.character_sprite.sprite_frames.get_frame_count(&"run") == 6, "Zombie dog run animation has six frames")
	_check(is_equal_approx(dog.character_sprite.sprite_frames.get_animation_speed(&"run"), 12.0), "Zombie dog run uses manifest playback speed")
	_check(dog.character_sprite.sprite_frames.has_animation(&"pounce"), "Zombie dog pounce animation exists")
	_check(dog.character_sprite.sprite_frames.has_animation(&"hurt"), "Zombie dog hurt animation exists")
	_check(dog.character_sprite.sprite_frames.has_animation(&"defeated"), "Zombie dog defeated animation exists")

	player.global_position = dog.global_position + Vector2(-160, 0)
	dog._update_facing()
	_check(not dog.character_sprite.flip_h, "Left-authored zombie dog displays as-is toward a player on the left")
	player.global_position = dog.global_position + Vector2(160, 0)
	dog._update_facing()
	_check(dog.character_sprite.flip_h, "Zombie dog mirrors toward a player on the right")

	player.global_position = dog.global_position + Vector2(-140, 0)
	dog.attack_cooldown = 0.0
	dog.state = ZombieDog.State.RUN
	dog._update_state(0.01)
	_check(dog.state == ZombieDog.State.TELEGRAPH, "Zombie dog crouches into a readable pounce telegraph")
	dog._update_state(dog.telegraph_duration + 0.01)
	dog._update_animation()
	_check(dog.state == ZombieDog.State.POUNCE and dog.pounce_direction < 0.0, "Zombie dog pounce launches toward the targeted player")
	_check(dog.character_sprite.animation == &"pounce", "Zombie dog pounce uses the authored action pose")

	dog.take_damage(1, Vector2.RIGHT)
	_check(dog.state == ZombieDog.State.RECOVER and dog.character_sprite.animation == &"hurt", "Damage cancels pounce and enters a hurt recovery")
	dog.take_damage(9999)
	_check(dog.is_dead and dog.character_sprite.animation == &"defeated", "Lethal damage holds the authored defeated pose")
	_check(not dog.is_in_group("enemies"), "Defeated zombie dog leaves the enemy target group")
	_check(defeated_events == 1, "Zombie dog emits one shared defeated signal")

	dog.queue_free()
	player.queue_free()
	_finish()

func _on_dog_defeated(_enemy: WaveEnemy) -> void:
	defeated_events += 1

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)

func _finish() -> void:
	if failures.is_empty():
		print("Zombie dog checks passed.")
		quit(0)
	else:
		printerr("Zombie dog checks failed: ", ", ".join(failures))
		quit(1)
