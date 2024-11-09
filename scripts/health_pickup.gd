extends Area2D

@export var heal_amount := 1

func _on_area_entered(area: Area2D) -> void:
	if area is Hurtbox:
		if area.health_component.health != area.health_component.MAX_HEALTH:
			queue_free()
		area.health_component.heal(heal_amount)
