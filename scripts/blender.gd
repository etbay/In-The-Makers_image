extends CharacterBody2D


@onready var ray_cast: RayCast2D = $RayCast2D
@onready var playerDection = $playerDection
@onready var floatingAnimation = $AnimationPlayer
@onready var damageTimer = $damageTimer


@export var speed = 200
@export var acceleration = 40
@export var knockback = 40
var friction = 20


var player : CharacterBody2D

func _ready():
	player = get_parent().find_child("Player")
	
	


func _physics_process(delta: float) -> void:
	find_player()

	velocity += get_gravity() * 0.6 * delta

	if damageTimer.is_stopped():
		velocity.x = move_toward(0, ray_cast.target_position.normalized().x * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, friction)
	move_and_slide()
	
	
	if velocity.x < 0:
		floatingAnimation.play("floatLeft")

	elif velocity.x > 0:
		floatingAnimation.play("floatRight")
	
	




func find_player():
	for area in playerDection.get_overlapping_areas():
		if area.name == "playerDetectbox":
			ray_cast.target_position = to_local(player.position)


func _on_health_component_damaged():
	damageTimer.start()
	if not player.dash_timeout.is_stopped():
		velocity.y = -300
		velocity.x = player.last_facing_direction.x * knockback
	else:
		velocity.x = player.last_facing_direction.x * knockback





func _on_health_component_died() -> void:
	self.queue_free()
