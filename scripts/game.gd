extends Node2D

@export var health_bar: ProgressBar
@export var health_component: HealthComponent


func _ready():
	if health_component and health_bar:
		health_component.health_bar = health_bar
	else:
		print("HealthComponent or HealthBar is not connected to root level node")
