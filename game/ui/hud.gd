class_name GameHud
extends CanvasLayer

const BOSS_HEALTH_FRAME: Texture2D = preload("res://assets/ui/stage1/boss_health_frame.png")

var health_label: Label
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
	health_label = _make_label(Vector2(24, 18), 24, Color("ffe3e3"))
	ammo_label = _make_label(Vector2(24, 52), 22, Color("fff3bf"))
	progression_label = _make_label(Vector2(24, 84), 18, Color("b2f2bb"))
	progression_label.size = Vector2(520, 32)
	wave_label = _make_label(Vector2(900, 18), 22, Color.WHITE)
	wave_label.size = Vector2(350, 36)
	wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	objective_label = _make_label(Vector2(900, 52), 20, Color("d0ebff"))
	objective_label.size = Vector2(350, 36)
	objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	banner_label = _make_label(Vector2(440, 96), 34, Color("ffe066"))
	banner_label.size = Vector2(400, 52)
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.visible = false

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

	message_panel = ColorRect.new()
	message_panel.position = Vector2(360, 245)
	message_panel.size = Vector2(560, 170)
	message_panel.color = Color(0.05, 0.07, 0.1, 0.88)
	message_panel.visible = false
	add_child(message_panel)

	message_label = Label.new()
	message_label.position = Vector2(20, 26)
	message_label.size = Vector2(520, 120)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 28)
	message_label.add_theme_color_override("font_color", Color.WHITE)
	message_panel.add_child(message_label)

func _process(delta: float) -> void:
	if banner_timer <= 0.0:
		return
	banner_timer = maxf(0.0, banner_timer - delta)
	if banner_timer <= 0.0:
		banner_label.visible = false

func _make_label(label_position: Vector2, font_size: int, font_color: Color) -> Label:
	var label := Label.new()
	label.position = label_position
	label.size = Vector2(340, 36)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(label)
	return label

func set_health(current: int, maximum: int) -> void:
	health_label.text = "HP  %d / %d" % [current, maximum]

func set_ammo(current: int, maximum: int) -> void:
	ammo_label.text = "AMMO  %02d / %02d" % [current, maximum]

func set_progression(level: int, experience: int, required: int, currency: int) -> void:
	progression_label.text = "LV %d   XP %d / %d   GEARS %d" % [level, experience, required, currency]

func set_wave(current: int, total: int, defeated: int, required: int) -> void:
	wave_label.text = "WAVE  %d / %d" % [current, total]
	objective_label.text = "REMAINING  %d" % maxi(0, required - defeated)

func show_wave_banner(current: int, total: int) -> void:
	banner_label.text = "WAVE %d / %d" % [current, total]
	banner_label.visible = true
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
	banner_label.visible = true
	banner_timer = 1.8

func show_result(title: String, subtitle: String) -> void:
	message_panel.visible = true
	message_label.text = "%s\n%s\n\nPress Enter" % [title, subtitle]
