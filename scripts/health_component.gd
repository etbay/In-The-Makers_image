extends Node2D
class_name HealthComponent

@export var player : CharacterBody2D
@export var MAX_HEALTH := 10
var health_bar: ProgressBar
var health : float

signal died
signal damaged
signal healed

func _ready():
	health = MAX_HEALTH
	call_deferred("initialize_health_bar")

func damage(attack):
	damaged.emit()
	health -= attack
	set_health_bar()
	if health <= 0:
		death()

func heal(heal):
	healed.emit()
	health += heal
	health = clamp(health, 0, MAX_HEALTH)
	set_health_bar()

func initialize_health_bar():
	if health_bar:
		health_bar.max_value = MAX_HEALTH
		health_bar.value = health
	else:
		print("WHY THE FUCK NOT")

func set_health_bar():
	if health_bar:
		health_bar.value = health

func death():
	died.emit()
	player.queue_free()
