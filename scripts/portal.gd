extends Node2D
class_name Portal

@export var connecting_portal : Portal
@onready var area_2d: Area2D = $Area2D

var teleported = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Hurtbox and not teleported:
		teleported = true
		area.health_component.player.global_position = connecting_portal.global_position
		connecting_portal.teleported = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area is Hurtbox:
		if teleported:
			teleported = false
			
