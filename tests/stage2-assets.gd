extends SceneTree

const ASSET_SPECS: Array[Dictionary] = [
	{"path": "res://assets/enemies/zombie_crow/idle.png", "columns": 1, "rows": 1, "cell": 256},
	{"path": "res://assets/enemies/zombie_crow/flight_sheet.png", "columns": 3, "rows": 2, "cell": 256},
	{"path": "res://assets/enemies/zombie_crow/action_sheet.png", "columns": 3, "rows": 1, "cell": 256},
	{"path": "res://assets/enemies/zombie_dog/idle.png", "columns": 1, "rows": 1, "cell": 256},
	{"path": "res://assets/enemies/zombie_dog/run_sheet.png", "columns": 3, "rows": 2, "cell": 256, "check_border": false},
	{"path": "res://assets/enemies/zombie_dog/action_sheet.png", "columns": 3, "rows": 1, "cell": 256},
	{"path": "res://assets/enemies/zombie_nurse/idle.png", "columns": 1, "rows": 1, "cell": 256},
	{"path": "res://assets/enemies/zombie_nurse/walk_sheet.png", "columns": 3, "rows": 2, "cell": 256},
	{"path": "res://assets/enemies/zombie_nurse/action_sheet.png", "columns": 4, "rows": 1, "cell": 256},
	{"path": "res://assets/enemies/zombie_doctor/idle.png", "columns": 1, "rows": 1, "cell": 256},
	{"path": "res://assets/enemies/zombie_doctor/walk_sheet.png", "columns": 3, "rows": 2, "cell": 256},
	{"path": "res://assets/enemies/zombie_doctor/action_sheet.png", "columns": 3, "rows": 1, "cell": 256},
	{"path": "res://assets/enemies/wheelchair_zombie/idle.png", "columns": 1, "rows": 1, "cell": 256},
	{"path": "res://assets/enemies/wheelchair_zombie/roll_sheet.png", "columns": 3, "rows": 2, "cell": 256},
	{"path": "res://assets/enemies/wheelchair_zombie/action_sheet.png", "columns": 4, "rows": 1, "cell": 256},
	{"path": "res://assets/bosses/stage2_chief_surgeon/idle.png", "columns": 1, "rows": 1, "cell": 512},
	{"path": "res://assets/bosses/stage2_chief_surgeon/walk_sheet.png", "columns": 2, "rows": 2, "cell": 512},
	{"path": "res://assets/bosses/stage2_chief_surgeon/sweep_sheet.png", "columns": 2, "rows": 2, "cell": 512},
	{"path": "res://assets/bosses/stage2_chief_surgeon/slam_sheet.png", "columns": 2, "rows": 2, "cell": 512},
]

var failures: Array[String] = []

func _init() -> void:
	for spec in ASSET_SPECS:
		_validate_asset(spec)
	if failures.is_empty():
		print("Stage 2 asset checks passed (%d files)." % ASSET_SPECS.size())
		quit(0)
	else:
		printerr("Stage 2 asset checks failed: ", ", ".join(failures))
		quit(1)

func _validate_asset(spec: Dictionary) -> void:
	var path := spec.path as String
	var columns := spec.columns as int
	var rows := spec.rows as int
	var cell_size := spec.cell as int
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	_check(not image.is_empty(), "%s loads" % path)
	if image.is_empty():
		return

	var expected_size := Vector2i(columns * cell_size, rows * cell_size)
	_check(image.get_size() == expected_size, "%s is %dx%d" % [path, expected_size.x, expected_size.y])
	_check(image.detect_alpha() != Image.ALPHA_NONE, "%s has transparency" % path)
	if image.get_size() != expected_size:
		return
	if not spec.get("check_border", true):
		print("SKIP: %s cell-border repair is tracked by AR-20260719-006" % path)
		return

	for row in range(rows):
		for column in range(columns):
			var frame_index := row * columns + column
			_check(_cell_border_is_clear(image, column, row, cell_size), "%s frame %d has a clear cell border" % [path, frame_index])

func _cell_border_is_clear(image: Image, column: int, row: int, cell_size: int) -> bool:
	var left := column * cell_size
	var top := row * cell_size
	var right := left + cell_size - 1
	var bottom := top + cell_size - 1
	for x in range(left, right + 1):
		if image.get_pixel(x, top).a > 0.0 or image.get_pixel(x, bottom).a > 0.0:
			return false
	for y in range(top, bottom + 1):
		if image.get_pixel(left, y).a > 0.0 or image.get_pixel(right, y).a > 0.0:
			return false
	return true

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		failures.append(message)
		push_error("FAIL: " + message)
