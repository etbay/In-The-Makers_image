extends CharacterBody2D



@onready var animation = $AnimationPlayer
@onready var timerbombguy = $"."
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var playerDection = $playerDetection
@onready var timeTillLaunch = $timetilllaunch
@onready var timeTillExplosion = $explosionTimer
@onready var pauseTimer = $pauseTimer
@onready var walkingSprite = $Sprite2D
@onready var explosionSprite = $explosion
@onready var characterSprite = $Sprite2D
@onready var explodingTimer = $exploding
@onready var explosionCollisionShape = $Hitbox/CollisionShape2D

@export var speed = 120
@export var acceleration = 40
@export var knockback = 40
var exploding = false
var waiting = true

var player : Player

func _ready():
	explosionCollisionShape.disabled = true
	explosionSprite.visible = false
	player = get_parent().find_child("Player")



func _physics_process(delta: float) -> void:
	find_player()
	if !exploding:
		velocity += get_gravity() * 0.6 * delta
		velocity.x = move_toward(0, ray_cast.target_position.normalized().x * speed, acceleration)
		move_and_slide()
		if velocity.x < 0:
			animation.play("walking")
		elif velocity.x > 0:
			animation.play("walking")
			animation.speed_scale = -1
		else:
			animation.stop()
		
	if waiting and exploding:
		velocity = Vector2.ZERO
	
	if exploding and !waiting:
		velocity += get_gravity() * 0.6 * delta
		move_and_slide()



	
	


func find_player():
	for area in playerDection.get_overlapping_areas():
		if area.name == "playerDetectbox":
			ray_cast.target_position = to_local(player.position)



func _on_player_detection_area_entered(area):
	if area.name == "playerDetectbox":
		timeTillLaunch.start()
		await timeTillLaunch.timeout
		exploding = true
		pauseTimer.start()
		await pauseTimer.timeout
		waiting = false
		explode()





func explode():
	var direction = to_local(player.position).normalized()
	speed = 320

	animation.stop()
	velocity.x = direction.x * speed
	velocity.y = direction.y * speed
	
	
	timeTillExplosion.start()
	await timeTillExplosion.timeout
	characterSprite.visible = false
	explosionSprite.visible = true
	explosionCollisionShape.disabled = false
	animation.play("walking")
	explodingTimer.start()
	await explodingTimer.timeout

	queue_free()
