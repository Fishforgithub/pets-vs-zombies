class_name GameHud
extends CanvasLayer

const BOSS_HEALTH_FRAME: Texture2D = preload("res://assets/ui/stage1/boss_health_frame.png")

var health_label: Label
var health_bar: ProgressBar
var ammo_label: Label
var progression_label: Label
var wave_label: Label
var objective_label: Label
var banner_label: Label
var banner_timer: float = 0.0
var boss_panel: ColorRect
var boss_name_label: Label
var boss_health_bar: ProgressBar
var boss_frame: TextureRect
var message_panel: ColorRect
var message_label: Label

func _ready() -> void:
	_setup_survival_panel()
	_setup_objective_panel()
	_setup_banner()
	_setup_boss_panel()
	_setup_message_panel()

func _setup_survival_panel() -> void:
	var survival_panel := _make_panel(Vector2(18, 12), Vector2(326, 148), Color(0.025, 0.065, 0.11, 0.9), Color("4cc9f0"))
	var section_label := _make_label(survival_panel, Vector2(14, 8), Vector2(290, 22), 13, Color("8ecae6"))
	section_label.text = "SURVIVAL STATUS"
	health_label = _make_label(survival_panel, Vector2(14, 31), Vector2(296, 28), 21, Color("ffe3e3"))
	health_bar = _make_progress_bar(Vector2(14, 60), Vector2(296, 16), Color("ff6b6b"), Color("4a1c28"))
	survival_panel.add_child(health_bar)
	ammo_label = _make_label(survival_panel, Vector2(14, 82), Vector2(296, 22), 18, Color("fff3bf"))
	progression_label = _make_label(survival_panel, Vector2(14, 108), Vector2(296, 22), 14, Color("b2f2bb"))
	progression_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

func _setup_objective_panel() -> void:
	var objective_panel := _make_panel(Vector2(928, 12), Vector2(334, 94), Color(0.025, 0.065, 0.11, 0.9), Color("90dbf4"))
	var section_label := _make_label(objective_panel, Vector2(14, 8), Vector2(306, 22), 13, Color("a9def9"))
	section_label.text = "MISSION STATUS"
	section_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	wave_label = _make_label(objective_panel, Vector2(14, 33), Vector2(306, 28), 21, Color.WHITE)
	wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	objective_label = _make_label(objective_panel, Vector2(14, 60), Vector2(306, 24), 17, Color("d0ebff"))
	objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

func _setup_banner() -> void:
	var banner_panel := _make_panel(Vector2(414, 108), Vector2(452, 54), Color(0.035, 0.055, 0.09, 0.9), Color("ffe066"))
	banner_panel.name = "EncounterBanner"
	banner_label = _make_label(banner_panel, Vector2(12, 6), Vector2(428, 42), 28, Color("ffe066"))
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_panel.visible = false
	banner_label.set_meta("panel", banner_panel)

func _setup_boss_panel() -> void:
	boss_panel = ColorRect.new()
	boss_panel.position = Vector2(320, 8)
	boss_panel.size = Vector2(640, 96)
	boss_panel.color = Color(0.16, 0.05, 0.06, 0.9)
	boss_panel.visible = false
	add_child(boss_panel)

	boss_health_bar = ProgressBar.new()
	boss_health_bar.position = Vector2(60, 16)
	boss_health_bar.size = Vector2(520, 64)
	boss_health_bar.show_percentage = false
	boss_health_bar.add_theme_stylebox_override("background", _make_style_box(Color("3b1b24"), Color("ff9f1c"), 2, 0))
	boss_health_bar.add_theme_stylebox_override("fill", _make_style_box(Color("d62828"), Color("ffdd57"), 2, 0))
	boss_panel.add_child(boss_health_bar)

	boss_name_label = Label.new()
	boss_name_label.position = Vector2(60, 16)
	boss_name_label.size = Vector2(520, 64)
	boss_name_label.text = "UNDEAD FOREMAN"
	boss_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	boss_name_label.add_theme_font_size_override("font_size", 18)
	boss_name_label.add_theme_color_override("font_color", Color("fff3bf"))
	boss_name_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	boss_name_label.add_theme_constant_override("shadow_offset_x", 2)
	boss_name_label.add_theme_constant_override("shadow_offset_y", 2)
	boss_panel.add_child(boss_name_label)

	boss_frame = TextureRect.new()
	boss_frame.name = "ProductionFrame"
	boss_frame.position = Vector2.ZERO
	boss_frame.size = Vector2(640, 96)
	boss_frame.texture = BOSS_HEALTH_FRAME
	boss_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	boss_frame.stretch_mode = TextureRect.STRETCH_KEEP
	boss_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_panel.add_child(boss_frame)

func _setup_message_panel() -> void:
	message_panel = ColorRect.new()
	message_panel.position = Vector2(360, 245)
	message_panel.size = Vector2(560, 170)
	message_panel.color = Color(0.05, 0.07, 0.1, 0.92)
	message_panel.visible = false
	add_child(message_panel)

	message_label = Label.new()
	message_label.position = Vector2(20, 26)
	message_label.size = Vector2(520, 120)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 28)
	message_label.add_theme_color_override("font_color", Color.WHITE)
	message_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	message_label.add_theme_constant_override("shadow_offset_x", 2)
	message_label.add_theme_constant_override("shadow_offset_y", 2)
	message_panel.add_child(message_label)

func _process(delta: float) -> void:
	if banner_timer <= 0.0:
		return
	banner_timer = maxf(0.0, banner_timer - delta)
	if banner_timer <= 0.0:
		_get_banner_panel().visible = false

func _make_panel(panel_position: Vector2, panel_size: Vector2, background: Color, border: Color) -> Panel:
	var panel := Panel.new()
	panel.position = panel_position
	panel.size = panel_size
	panel.add_theme_stylebox_override("panel", _make_style_box(background, border, 2, 6))
	add_child(panel)
	return panel

func _make_style_box(background: Color, border: Color, border_width: int, corner_radius: int) -> StyleBoxFlat:
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = background
	style_box.border_color = border
	style_box.border_width_left = border_width
	style_box.border_width_top = border_width
	style_box.border_width_right = border_width
	style_box.border_width_bottom = border_width
	style_box.corner_radius_top_left = corner_radius
	style_box.corner_radius_top_right = corner_radius
	style_box.corner_radius_bottom_right = corner_radius
	style_box.corner_radius_bottom_left = corner_radius
	return style_box

func _make_progress_bar(bar_position: Vector2, bar_size: Vector2, fill_color: Color, background_color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = bar_position
	bar.size = bar_size
	bar.show_percentage = false
	bar.add_theme_stylebox_override("background", _make_style_box(background_color, Color("6c757d"), 1, 4))
	bar.add_theme_stylebox_override("fill", _make_style_box(fill_color, Color("fff3bf"), 1, 4))
	return bar

func _make_label(parent: Control, label_position: Vector2, label_size: Vector2, font_size: int, font_color: Color) -> Label:
	var label := Label.new()
	label.position = label_position
	label.size = label_size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	parent.add_child(label)
	return label

func _get_banner_panel() -> Panel:
	return banner_label.get_meta("panel") as Panel

func set_health(current: int, maximum: int) -> void:
	health_label.text = "HP  %d / %d" % [current, maximum]
	health_bar.max_value = maximum
	health_bar.value = current

func set_ammo(current: int, maximum: int) -> void:
	ammo_label.text = "AMMO  %02d / %02d" % [current, maximum]

func set_progression(level: int, experience: int, required: int, currency: int) -> void:
	progression_label.text = "LV %d  XP %d/%d  G %d" % [level, experience, required, currency]

func set_wave(current: int, total: int, defeated: int, required: int) -> void:
	wave_label.text = "WAVE  %d / %d" % [current, total]
	objective_label.text = "REMAINING  %d" % maxi(0, required - defeated)

func show_wave_banner(current: int, total: int) -> void:
	banner_label.text = "WAVE %d / %d" % [current, total]
	_get_banner_panel().visible = true
	banner_timer = 1.2

func set_objective(defeated: int, required: int) -> void:
	objective_label.text = "ZOMBIES  %d / %d" % [defeated, required]

func show_boss(maximum: int) -> void:
	boss_health_bar.max_value = maximum
	boss_health_bar.value = maximum
	boss_panel.visible = true

func set_boss_health(current: int, maximum: int) -> void:
	boss_health_bar.max_value = maximum
	boss_health_bar.value = current

func hide_boss() -> void:
	boss_panel.visible = false

func show_boss_banner(boss_name: String) -> void:
	banner_label.text = boss_name
	_get_banner_panel().visible = true
	banner_timer = 1.8

func show_result(title: String, subtitle: String) -> void:
	message_panel.visible = true
	message_label.text = "%s\n%s\n\nPress Enter" % [title, subtitle]
