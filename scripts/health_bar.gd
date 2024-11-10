extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var player : Player
@onready var death: Timer = $Death

func _ready() -> void:
	animation_player.play("Start")

func _process(delta: float) -> void:
	if player.dead and player.death_timer.is_stopped():
		death.wait_time = player.death_timer.wait_time - 1
		death.start()


func _on_death_timeout() -> void:
	animation_player.play("Death")
