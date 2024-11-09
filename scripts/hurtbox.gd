extends Area2D
class_name Hurtbox

@export var health_component : Node2D

func _ready():
	monitoring = true

func _on_area_entered(area: Hitbox) -> void:
	health_component.damage(area.attack_damage)
