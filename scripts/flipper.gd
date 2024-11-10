extends CharacterBody2D




@onready var ray_cast: RayCast2D = $RayCast2D
@onready var playerDection = $playerDetection
@onready var sprite = $Sprite2D
@onready var flippingAnimation = $AnimationPlayer
@onready var flippingTimer = $flippingTimer
@onready var damageLength = $damageLength


@export var launchingPower = -150
@export var speed = 120
@export var acceleration = 40
@export var knockback = 40
var friction = 20
var flipping = false


var player : CharacterBody2D

func _ready():
	player = get_parent().find_child("Player")
	
	


func _physics_process(delta: float) -> void:
	find_player()
	
	velocity += get_gravity() * 0.6 * delta
	if damageLength.is_stopped():
		velocity.x = move_toward(0, ray_cast.target_position.normalized().x * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, friction)
	move_and_slide()
	
	if !flipping: 
		if velocity.x < 0:
			flippingAnimation.play("walkingLeft")

		elif velocity.x > 0:
			flippingAnimation.play("walkingRight")

	




func find_player():
	for area in playerDection.get_overlapping_areas():
		if area.name == "playerDetectbox":
			ray_cast.target_position = to_local(player.position)


func _on_launching_area_area_entered(_area):
	flipping = true
	flippingAnimation.stop()
	if velocity.x < 0:
		flippingAnimation.play("flipping")
		flippingTimer.start()
		await flippingTimer.timeout
		flippingAnimation.stop()
	elif velocity.x > 0:
		flippingAnimation.play("flippingRight")
		flippingTimer.start()
		await flippingTimer.timeout
		flippingAnimation.stop()
	flipping = false








func _on_health_component_damaged() -> void:
	print(player.last_facing_direction.x)
	damageLength.start()
	if not player.dash_timeout.is_stopped():
		velocity.y = -300
		velocity.x = player.last_facing_direction.x * knockback
	else:
		velocity.x = player.last_facing_direction.x * knockback
