class_name WaveEnemy
extends CharacterBody2D

signal defeated(enemy: WaveEnemy)
signal support_buff_changed(active: bool)

@export var experience_reward: int = 18
@export var currency_reward: int = 12

var support_buff_timer: float = 0.0
var support_speed_multiplier: float = 1.0

func apply_support_buff(duration: float, speed_multiplier: float) -> void:
	var was_active := support_buff_timer > 0.0
	support_buff_timer = maxf(support_buff_timer, duration)
	support_speed_multiplier = maxf(support_speed_multiplier, speed_multiplier)
	if not was_active:
		support_buff_changed.emit(true)

func update_support_buff(delta: float) -> void:
	if support_buff_timer <= 0.0:
		return
	support_buff_timer = maxf(0.0, support_buff_timer - delta)
	if support_buff_timer > 0.0:
		return
	support_speed_multiplier = 1.0
	support_buff_changed.emit(false)

func get_support_speed_multiplier() -> float:
	return support_speed_multiplier if support_buff_timer > 0.0 else 1.0
