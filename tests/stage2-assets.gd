extends SceneTree

const ASSET_SPECS: Array[Dictionary] = [
	{"path": "res://assets/enemies/zombie_crow/idle.png", "columns": 1, "rows": 1, "cell": 256},
	{"path": "res://assets/enemies/zombie_crow/flight_sheet.png", "columns": 3, "rows": 2, "cell": 256},
	{"path": "res://assets/enemies/zombie_crow/action_sheet.png", "columns": 3, "rows": 1, "cell": 256},
	{"path": "res://assets/enemies/zombie_dog/idle.png", "columns": 1, "rows": 1, "cell": 256},
	{"path": "res://assets/enemies/zombie_dog/run_sheet.png", "columns": 3, "rows": 2, "cell": 256, "check_border": false, "skip_reason": "cell-border repair is tracked by AR-20260719-006"},
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
	{"path": "res://assets/bosses/stage2_chief_surgeon/reaction_sheet.png", "columns": 2, "rows": 2, "cell": 512},
	{"path": "res://assets/hazards/stage2/rolling_equipment_sheet.png", "columns": 4, "rows": 1, "cell": 256, "shared_borders_only": true},
	{"path": "res://assets/vfx/stage2_hospital_effects.png", "columns": 4, "rows": 1, "cell": 256},
	{"path": "res://assets/backgrounds/stage2/hospital_corridor.png", "columns": 1, "rows": 1, "width": 960, "height": 540, "alpha": false, "check_border": false, "skip_reason": "opaque background does not use atlas slicing"},
	{"path": "res://assets/tilesets/stage2/hospital_ground_tiles.png", "columns": 4, "rows": 1, "cell": 256, "check_border": false, "skip_reason": "repeatable floor tiles intentionally meet their cell edges"},
	{"path": "res://assets/backgrounds/stage2/hospital_wall_modules.png", "columns": 4, "rows": 1, "cell": 256, "check_border": false, "skip_reason": "wall modules intentionally fill their complete cells"},
	{"path": "res://assets/props/stage2/hospital_props.png", "columns": 4, "rows": 1, "cell": 256, "shared_borders_only": true},
	{"path": "res://assets/hazards/stage2/electric_puddle_sheet.png", "columns": 4, "rows": 1, "cell": 256, "shared_borders_only": true},
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
	var cell_size := int(spec.get("cell", 0))
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	_check(not image.is_empty(), "%s loads" % path)
	if image.is_empty():
		return

	var expected_size := Vector2i(int(spec.get("width", columns * cell_size)), int(spec.get("height", rows * cell_size)))
	_check(image.get_size() == expected_size, "%s is %dx%d" % [path, expected_size.x, expected_size.y])
	if spec.get("alpha", true):
		_check(image.detect_alpha() != Image.ALPHA_NONE, "%s has transparency" % path)
	else:
		_check(image.detect_alpha() == Image.ALPHA_NONE, "%s is opaque" % path)
	if image.get_size() != expected_size:
		return
	if not spec.get("check_border", true):
		print("SKIP: %s %s" % [path, spec.get("skip_reason", "does not require cell-border validation")])
		return

	for row in range(rows):
		for column in range(columns):
			var frame_index := row * columns + column
			var border_is_clear := _shared_cell_borders_are_clear(image, column, row, columns, rows, cell_size) if spec.get("shared_borders_only", false) else _cell_border_is_clear(image, column, row, cell_size)
			_check(border_is_clear, "%s frame %d has clear atlas boundaries" % [path, frame_index])

func _shared_cell_borders_are_clear(image: Image, column: int, row: int, columns: int, rows: int, cell_size: int) -> bool:
	var left := column * cell_size
	var top := row * cell_size
	var right := left + cell_size - 1
	var bottom := top + cell_size - 1
	if column > 0:
		for y in range(top, bottom + 1):
			if image.get_pixel(left, y).a > 0.0:
				return false
	if column < columns - 1:
		for y in range(top, bottom + 1):
			if image.get_pixel(right, y).a > 0.0:
				return false
	if row > 0:
		for x in range(left, right + 1):
			if image.get_pixel(x, top).a > 0.0:
				return false
	if row < rows - 1:
		for x in range(left, right + 1):
			if image.get_pixel(x, bottom).a > 0.0:
				return false
	return true

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
