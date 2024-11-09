extends Node2D
class_name HealthComponent

@export var player : Player
@export var MAX_HEALTH := 10.0
var health : float

signal died
signal damaged

func _ready():
	health = MAX_HEALTH

func damage(attack):
	damaged.emit()
	health -= attack
	if health < 0:
		death()

func death():
	died.emit()
	player.queue_free()
