extends Node2D

var direction : Vector2 = Vector2.RIGHT
var speed := 300.0

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _screen_exited() -> void:
	queue_free()
