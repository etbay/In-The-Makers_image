extends Node2D

@export var health_bar: ProgressBar
@export var health_component: HealthComponent


func _ready():
	if health_component and health_bar:
		health_component.health_bar = health_bar
	else:
		print("HealthComponent or HealthBar is not connected to root level node")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
