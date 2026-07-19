class_name WaveEnemy
extends CharacterBody2D

signal defeated(enemy: WaveEnemy)

@export var experience_reward: int = 18
@export var currency_reward: int = 12
