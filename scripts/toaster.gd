extends CharacterBody2D

@onready var detect_cliff: RayCast2D = $DetectCliff
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var move_time: Timer = $MoveTime
@export var ammo : PackedScene
@onready var health_component: HealthComponent = $HealthComponent
@onready var damaged_length: Timer = $DamagedLength
@onready var shoot_time: Timer = $ShootTime
@onready var move_to_player: Timer = $MoveToPlayer
@onready var attack_audio: AudioStreamPlayer2D = $Audio/AttackAudio
@onready var damaged_audio: AudioStreamPlayer2D = $Audio/DamagedAudio
@onready var death_timer: Timer = $DeathTimer

const BASE_SPEED = 40

@export var speed = 40
@export var acceleration = 30
var friction = 20
@export var knockback = 400
var being_attacked = false
var moving = true
var on_screen = false
var active = false
var dead = false

var player : Player

func _ready():
	player = get_parent().find_child("Player")
	move_time.start()

func _physics_process(delta: float) -> void:
	#print(not move_time.is_stopped())
	#print(not shoot_time.is_stopped())
	if dead and death_timer.is_stopped():
		self.queue_free()
	if not detect_cliff.is_colliding() and damaged_length.is_stopped():
		move_to_player.start()
	
	if active:
		aim()
		velocity.y += get_gravity().y * 0.5 * delta
		var dir = -1
		if not move_to_player.is_stopped():
			dir = 1
		if damaged_length.is_stopped():
			if not move_time.is_stopped():
				velocity.x = move_toward(velocity.x, ray_cast.target_position.normalized().x * speed * dir, acceleration)
			elif not shoot_time.is_stopped():
				velocity.x = move_toward(velocity.x, 0, friction)
		else:
			move_time.stop()
			shoot_time.stop()
			velocity.x = move_toward(velocity.x, 0, friction)
		move_and_slide()

func aim():
	if is_instance_valid(player):
		ray_cast.target_position = to_local(player.position)

func shoot():
	if is_on_floor() and is_instance_valid(player):
		var bullet1 = ammo.instantiate()
		var bullet2 = ammo.instantiate()
		bullet1.position = position
		bullet1.direction.x = (ray_cast.target_position).normalized().x
		bullet2.position = position
		bullet2.direction.x = (ray_cast.target_position).normalized().x
		get_tree().current_scene.add_child(bullet1)
		get_tree().current_scene.add_child(bullet2)

func _on_health_component_damaged() -> void:
	damaged_audio.play()
	damaged_length.start()
	move_to_player.stop()
	speed += 50
	if player.dashing or player.uppercutting:
		velocity.y = -300
	else:
		velocity.y = -100
	velocity.x = player.last_facing_direction.x * knockback

func _on_shoot_time_timeout() -> void:
	shoot()
	move_time.start()

func _on_move_time_timeout() -> void:
	speed = BASE_SPEED
	shoot_time.start()

func _on_damaged_length_timeout() -> void:
	move_time.start()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	active = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	move_to_player.start()

func _on_health_component_died() -> void:
	dead = true
	death_timer.start()
	damaged_audio.play()
