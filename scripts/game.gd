extends Node2D

@export var health_bar: ProgressBar
@export var health_component: HealthComponent


func _ready():
	if health_component and health_bar:
		health_component.health_bar = health_bar
	else:
		print("HealthComponent or HealthBar is not connected to root level node")
	AudioServer.set_bus_mute(1, false)
	if name == "Level 1":
		Music1.play()
		Music2.stop()
		MainMenuMusic.stop()
		VictoryScreen.stop()
	elif name == "MainMenu":
		Music1.stop()
		Music2.stop()
		MainMenuMusic.play()
		VictoryScreen.stop()
	elif name == "Level 2":
		Music1.stop()
		Music2.play()
		MainMenuMusic.stop()
		VictoryScreen.stop()
	elif name == "VictoryLevel":
		Music1.stop()
		Music2.stop()
		MainMenuMusic.stop()
		VictoryScreen.play()
		

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
