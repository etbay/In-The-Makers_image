extends CharacterBody2D

@onready var ray_cast: RayCast2D = $RayCast2D
@onready var timer: Timer = $Timer
@export var ammo : PackedScene
@onready var health_component: HealthComponent = $HealthComponent

var player : CharacterBody2D

func _ready():
	player = get_parent().find_child("Player")

func _physics_process(delta: float) -> void:
	aim()
	check_player_collision()
	print(health_component.health)
	velocity += get_gravity() * delta
	move_and_slide()

func aim():
	if is_instance_valid(player):
		ray_cast.target_position = to_local(player.position)

func check_player_collision():
	if ray_cast.get_collider() == player and timer.is_stopped():
		timer.start()
	elif ray_cast.get_collider() != player and not timer.is_stopped():
		timer.stop()

func shoot():
	var bullet = ammo.instantiate()
	bullet.position = position
	bullet.direction.x = (ray_cast.target_position).normalized().x
	get_tree().current_scene.add_child(bullet)

func _on_timer_timeout() -> void:
	shoot()

func _on_health_component_damaged() -> void:
	velocity.y = -300
