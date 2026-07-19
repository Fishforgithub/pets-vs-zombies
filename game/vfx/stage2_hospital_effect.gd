class_name Stage2HospitalEffect
extends Sprite2D

@export_range(0, 3) var effect_index: int = 0
@export var presentation_duration: float = 0.28

var remaining: float

func _ready() -> void:
	_apply_effect_region()
	remaining = presentation_duration

func configure(index: int, duration: float = 0.28) -> void:
	effect_index = clampi(index, 0, 3)
	presentation_duration = maxf(0.05, duration)
	remaining = presentation_duration
	_apply_effect_region()

func _process(delta: float) -> void:
	remaining = maxf(0.0, remaining - delta)
	var progress := remaining / presentation_duration
	modulate.a = clampf(progress * 1.7, 0.0, 1.0)
	if remaining <= 0.0:
		queue_free()

func _apply_effect_region() -> void:
	region_enabled = true
	region_rect = Rect2(effect_index * 256.0, 0.0, 256.0, 256.0)
