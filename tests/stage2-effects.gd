extends SceneTree

var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var effect_scene := load("res://game/vfx/stage2_hospital_effect.tscn") as PackedScene
	_check(effect_scene != null, "Stage 2 hospital effect scene loads")
	if effect_scene == null:
		_finish()
		return

	var host := Node2D.new()
	root.add_child(host)
	for effect_index in range(4):
		var effect := effect_scene.instantiate() as Stage2HospitalEffect
		host.add_child(effect)
		effect.configure(effect_index, 0.2)
		_check(effect.region_enabled, "Hospital effect %d uses atlas region slicing" % effect_index)
		_check(effect.region_rect == Rect2(effect_index * 256.0, 0.0, 256.0, 256.0), "Hospital effect %d selects its documented cell" % effect_index)
		_check(effect.get_child_count() == 0, "Hospital effect %d is presentation-only without collision" % effect_index)
		effect._process(0.2)
		_check(effect.is_queued_for_deletion(), "Hospital effect %d removes itself after presentation" % effect_index)

	host.queue_free()
	_finish()

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)

func _finish() -> void:
	if failures.is_empty():
		print("Stage 2 hospital effect checks passed.")
		quit(0)
	else:
		printerr("Stage 2 hospital effect checks failed: ", ", ".join(failures))
		quit(1)
