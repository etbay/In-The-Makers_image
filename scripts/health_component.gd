extends Node2D
class_name HealthComponent

@export var player : CharacterBody2D
@export var MAX_HEALTH := 10.0
var health : float

signal died
signal damaged
signal healed

func _ready():
	health = MAX_HEALTH

func damage(attack):
	damaged.emit()
	health -= attack
	if health <= 0:
		death()

func heal(heal):
	healed.emit()
	health += heal
	health = clamp(health, 0, MAX_HEALTH)

func death():
	died.emit()
	player.queue_free()
