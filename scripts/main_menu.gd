extends Control
class_name MainMenu

@onready var start_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/StartButton
@onready var exit_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/ExitButton

@export var start_level = preload("res://scenes/level_1.tscn") as PackedScene

func _ready():
	handle_connecting_signals()

func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(start_level)

func on_exit_pressed() -> void:
	get_tree().quit()

func handle_connecting_signals() -> void:
	start_button.button_up.connect(on_start_pressed)
	exit_button.button_up.connect(on_exit_pressed)
