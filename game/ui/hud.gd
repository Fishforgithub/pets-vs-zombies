class_name GameHud
extends CanvasLayer

var health_label: Label
var ammo_label: Label
var objective_label: Label
var message_panel: ColorRect
var message_label: Label

func _ready() -> void:
	health_label = _make_label(Vector2(24, 18), 24, Color("ffe3e3"))
	ammo_label = _make_label(Vector2(24, 52), 22, Color("fff3bf"))
	objective_label = _make_label(Vector2(920, 18), 22, Color.WHITE)
	objective_label.size = Vector2(330, 40)
	objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

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

func set_objective(defeated: int, required: int) -> void:
	objective_label.text = "ZOMBIES  %d / %d" % [defeated, required]

func show_result(title: String, subtitle: String) -> void:
	message_panel.visible = true
	message_label.text = "%s\n%s\n\nPress Enter" % [title, subtitle]

