extends Node2D



func _on_area_2d_body_entered(body: Node2D) -> void:
	var current_scene = get_tree().current_scene.name
	if body is Player:
		if current_scene == "Level 1":
			get_tree().change_scene_to_file("res://scenes/level_2.tscn")
		elif current_scene == "Level 2":
			pass
