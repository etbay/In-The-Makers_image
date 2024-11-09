extends CharacterBody2D

@onready var ray_cast: RayCast2D = $RayCast2D
@onready var timer: Timer = $Timer
@export var ammo : PackedScene
@onready var health_component: HealthComponent = $HealthComponent
@onready var damaged_length: Timer = $DamagedLength

@export var speed = 40
@export var acceleration = 20
var friction = 20
@export var knockback = 40
var being_attacked = false

var player : CharacterBody2D

func _ready():
	player = get_parent().find_child("Player")

func _physics_process(delta: float) -> void:
	aim()
	check_player_collision()
	#print(health_component.health)
	velocity += get_gravity() * 0.6 * delta
	if damaged_length.is_stopped():
		velocity.x = move_toward(0, ray_cast.target_position.normalized().x * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, friction)
	move_and_slide()

func aim():
	if is_instance_valid(player):
		ray_cast.target_position = to_local(player.position)

func check_player_collision():
	if player:
		if ray_cast.get_collider() == player and timer.is_stopped():
			timer.start()
		elif ray_cast.get_collider() != player and not timer.is_stopped():
			timer.stop()

func shoot():
	if is_on_floor() and is_instance_valid(player):
		var bullet1 = ammo.instantiate()
		var bullet2 = ammo.instantiate()
		var bullet3 = ammo.instantiate()
		bullet1.position = position
		bullet1.direction.x = (ray_cast.target_position).normalized().x
		bullet2.position = position
		bullet2.direction.x = (ray_cast.target_position).normalized().x
		bullet3.position = position
		bullet3.direction.x = (ray_cast.target_position).normalized().x
		get_tree().current_scene.add_child(bullet1)
		get_tree().current_scene.add_child(bullet2)
		get_tree().current_scene.add_child(bullet3)

func _on_timer_timeout() -> void:
	shoot()

func _on_health_component_damaged() -> void:
	damaged_length.start()
	if not player.dash_timeout.is_stopped():
		velocity.y = -300
		velocity.x = player.last_facing_direction.x * knockback
	else:
		velocity.x = player.last_facing_direction.x * knockback
