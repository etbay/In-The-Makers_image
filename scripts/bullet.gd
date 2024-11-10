extends Node2D

@onready var ray_cast: RayCast2D = $RayCast2D

var direction : Vector2 = Vector2.RIGHT
var speed := 300.0
var velocity = Vector2.ZERO
var gravity = 240

var rand = RandomNumberGenerator.new()

func _ready():
	var player = get_parent().find_child("Player")
	var start_pos = global_position
	var target_pos = player.global_position
	var time_to_target = 1.0
	
	target_pos.x += rand.randi_range(-30, 30)
	
	velocity = calculate_initial_velocity(start_pos, target_pos, gravity, time_to_target)

func _physics_process(delta: float) -> void:
	if ray_cast.is_colliding():
		queue_free()
	velocity.y += gravity * delta
	position += velocity * delta

func calculate_initial_velocity(start_pos, target_pos, gravity, time) -> Vector2:
	var delta_x = target_pos.x - start_pos.x
	var delta_y = target_pos.y - start_pos.y
	
	var v_x0 = delta_x / time
	var v_y0 = -1 * ((delta_y / time) + (0.5 * gravity * time))
	
	return Vector2(v_x0, v_y0)

func _screen_exited() -> void:
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	queue_free()
