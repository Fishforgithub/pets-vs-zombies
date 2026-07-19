extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed_scene := load("res://game/player/player.tscn") as PackedScene
	_check(packed_scene != null, "Player scene loads")
	if packed_scene == null:
		_finish()
		return

	var player := packed_scene.instantiate() as PlayerGirl
	root.add_child(player)
	await process_frame

	var frames := player.character_sprite.sprite_frames
	_check(frames.has_animation(&"crouch"), "Crouch animation exists")
	_check(frames.get_frame_count(&"crouch") == 1, "Crouch animation has one frame")
	var crouch_texture := frames.get_frame_texture(&"crouch", 0)
	_check(crouch_texture != null, "Crouch texture loads")
	if crouch_texture != null:
		_check(crouch_texture.get_size() == Vector2(256.0, 256.0), "Crouch texture is 256x256")
	var crouch_image := crouch_texture.get_image() if crouch_texture != null else Image.new()
	_check(crouch_image.get_used_rect().end.y == 230, "Crouch art uses the standard feet baseline")

	var standing_shape := player.standing_collision_shape.shape as CapsuleShape2D
	var crouch_shape := player.crouch_collision_shape.shape as CapsuleShape2D
	_check(standing_shape != null and crouch_shape != null, "Both collision shapes load")
	if standing_shape != null and crouch_shape != null:
		_check(crouch_shape.height < standing_shape.height, "Crouch collision is shorter")
		_check(
			is_equal_approx(
				player.standing_collision_shape.position.y + standing_shape.height * 0.5,
				player.crouch_collision_shape.position.y + crouch_shape.height * 0.5
			),
			"Collision shapes share a feet baseline"
		)

	player._update_crouch_state(true)
	_check(player.is_crouching, "Player enters crouch")
	_check(player.standing_collision_shape.disabled, "Standing collision disables while crouched")
	_check(not player.crouch_collision_shape.disabled, "Crouch collision enables while crouched")

	var ceiling := StaticBody2D.new()
	var ceiling_collision := CollisionShape2D.new()
	var ceiling_shape := RectangleShape2D.new()
	ceiling_shape.size = Vector2(100.0, 8.0)
	ceiling_collision.shape = ceiling_shape
	ceiling.add_child(ceiling_collision)
	ceiling.position = Vector2(0.0, -42.0)
	root.add_child(ceiling)
	await physics_frame

	player._update_crouch_state(false)
	_check(player.is_crouching, "Player stays crouched below an obstruction")

	ceiling.queue_free()
	await physics_frame
	player._update_crouch_state(false)
	_check(not player.is_crouching, "Player stands after obstruction clears")
	_check(not player.standing_collision_shape.disabled, "Standing collision re-enables")
	_check(player.crouch_collision_shape.disabled, "Crouch collision disables after standing")

	player.queue_free()
	_finish()

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)

func _finish() -> void:
	if failures.is_empty():
		print("Player crouch checks passed.")
		quit(0)
	else:
		printerr("Player crouch checks failed: ", ", ".join(failures))
		quit(1)
