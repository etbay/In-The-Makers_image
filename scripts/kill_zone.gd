extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.dead = true
		body.call_deferred("on_killzoned")
