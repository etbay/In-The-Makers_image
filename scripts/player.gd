extends CharacterBody2D
class_name Player

# TO-DO
# - Add Coyote Time

@onready var health_component: HealthComponent = $HealthComponent
@onready var dash_timeout: Timer = $DashTimeout
@onready var attacking: Timer = $Attacking
@onready var air_wait: Timer = $AirWait
@onready var attack_sound: AudioStreamPlayer2D = $Audio/AttackSound
@onready var aerial_attack_sound: AudioStreamPlayer2D = $Audio/AerialAttackSound
@onready var uppercut_sound: AudioStreamPlayer2D = $Audio/UppercutSound
@onready var footstep_sound: AudioStreamPlayer2D = $Audio/FootstepSound
@onready var footstep_interval: Timer = $FootstepInterval
@onready var pitch_timer: Timer = $PitchTimer
@export var tilemap : TileMapLayer
@onready var physics_hitbox: CollisionShape2D = $PhysicsHitbox
@onready var death_timer: Timer = $DeathTimer
@onready var landing_sound: AudioStreamPlayer2D = $Audio/LandingSound

const BASE_SPEED := 150.0
const RUN_SPEED := 250.0
const BASE_ACCELERATION := 20.0
const BASE_FRICTION := 20.0
const BASE_JUMP_VELOCITY := -300.0
const BASE_ENGINE_TIME_SCALE := 1.0
const MAX_DASHES := 1
var BASE_DASH_LENGTH_SECONDS := 0.2

var gravity_percent := 0.8
@export var speed = BASE_SPEED
var acceleration = BASE_ACCELERATION
var friction = BASE_FRICTION
var jump_velocity = BASE_JUMP_VELOCITY
var direction = Vector2.ZERO
var last_facing_direction = Vector2.RIGHT

var idling = true
var walking = false
var jumping = false
var dashing = false
var times_dashed := 0
var dash_speed := 300.0
var can_dash = true
var dash_length_seconds := BASE_DASH_LENGTH_SECONDS
var dash_length_distance := 250.0

var dead = false
var uppercutting = false
var times_aerial_attacked = 0

var state = State.IDLE
enum State
{
	IDLE,
	WALK,
	JUMP,
	DASH,
	DEAD
}

var attack_state = State.IDLE
enum Attacks
{
	IDLE,
	UPPER,
	AIR,
	BASIC,
}

func _ready():
	randomize()

func _physics_process(delta: float) -> void:
	#print("idling: " + str(idling))
	#print("walking: " + str(walking))
	#print("dashing: " + str(dashing))
	#print("jumping: " + str(jumping))
	#
	#print(death_timer.time_left)
	
	# Performs state actions based on active state; state is changed in state functions
	match state:
		State.IDLE:
			idle_state(delta)
		State.WALK:
			walk_state(delta)
		State.JUMP:
			jump_state(delta)
		State.DASH:
			dash_state(delta)
		State.DEAD:
			dead_state(delta)
	
	# Debugging function, left click to slow time
	set_engine_time()

func set_engine_time():
	if Input.is_action_pressed("slow_time"):
		Engine.time_scale = 0.1
	elif Input.is_action_just_released("slow_time"):
		Engine.time_scale = BASE_ENGINE_TIME_SCALE

# Checks state at the end of every iteration of state functions
# Returns false if state is not changed
# Return values used to update action variables (jumping, dashing, etc)
func change_state() -> bool:
	if dead:
		state = State.DEAD
		return true
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_ceiling()) and not jumping:
		state = State.JUMP
		return true
	elif Input.is_action_just_pressed("dash") and not dashing and times_dashed < MAX_DASHES and dash_timeout.is_stopped() and not uppercutting:
		state = State.DASH
		return true
	elif direction.x and not walking and (is_on_floor() or is_on_ceiling()):
		state = State.WALK
		return true
	elif not direction.x and not idling and (is_on_floor() or is_on_ceiling()):
		state = State.IDLE
		return true
	if Input.is_action_just_pressed("attack") and attacking.is_stopped():
		detect_attack_type()
		if attack_state == Attacks.UPPER and is_on_floor() and not uppercutting:
			upper_attack_state()
		if attack_state == Attacks.AIR and not is_on_floor():
			aerial_attack_state()
	elif is_on_floor():
		attack_state = Attacks.IDLE
		uppercutting = false
	else:
		attack_state = Attacks.IDLE
	return false

func idle_state(delta):
	idling = true
	get_direction()
	apply_gravity(delta)
	apply_horizontal_movement()
	move_and_slide()
	if change_state():
		idling = false
func walk_state(delta):
	if not footstep_sound.playing and footstep_interval.is_stopped() and is_on_floor():
		var rand_float = randf_range(-0.3,0.0)
		footstep_interval.start()
		footstep_sound.pitch_scale += rand_float
		footstep_sound.play()
		pitch_timer.start()
	walking = true
	get_direction()
	apply_gravity(delta)
	apply_horizontal_movement()
	move_and_slide()
	if change_state():
		walking = false
func jump_state(delta):
	if not jumping and (is_on_floor() or is_on_ceiling()):
		velocity.y = jump_velocity
	jumping = true
	get_direction()
	apply_gravity(delta)
	apply_horizontal_movement()
	move_and_slide()
	if change_state():
		jumping = false
func dash_state(delta):
	# Called one frame only
	# Increases times dashed, disables gravity, and adds dash velocity
	if not dashing and not uppercutting:
		dash_timeout.start()
		can_dash = false
		velocity.y = 0.0
		times_dashed += 1
		# If diagonal dashing, speed is changed
		# Normalized was too slow by itself on the diagonal
		#if last_facing_direction.y != 0.0 and last_facing_direction.x == 0.0:
		#	velocity = velocity.move_toward(last_facing_direction.normalized() * dash_length_distance * 0.8, dash_speed)
		#else:
		velocity.x = move_toward(velocity.x, last_facing_direction.normalized().x * dash_length_distance, dash_speed)
		dashing = true
	elif dash_length_seconds >= 0.0: 	# While dashing, update timer (dash length in seconds)
		dash_length_seconds -= 0.01
	move_and_slide()
	# Once timer ends, reset state
	# Times dashed is reset in apply gravity function once player hits ground
	if dash_length_seconds <= 0.0:
		dashing = false
		uppercutting = false
		# If jumping is not set to true, the player will jump immediately after dash, could be good for slide
		jumping = true
		state = State.JUMP
		dash_length_seconds = BASE_DASH_LENGTH_SECONDS
func dead_state(delta):
	apply_gravity(delta)
	velocity.x = move_toward(velocity.x, 0, friction)
	move_and_slide()
	if death_timer.is_stopped():
		death_timer.start()

func detect_attack_type():
	if attacking.is_stopped():
		if direction.y < 0.0 and is_on_floor():
			attack_state = Attacks.UPPER
		elif state == State.WALK or state == State.IDLE:
			attack_sound.play()
			attack_state = Attacks.BASIC
		elif state == State.JUMP and not is_on_floor():
			attack_state = Attacks.AIR
		attacking.start()

func upper_attack_state():
	if not uppercutting and is_on_floor() and not dashing:
		uppercut_sound.play()
		velocity.y = jump_velocity
	uppercutting = true

func aerial_attack_state():
	if not is_on_floor() and times_aerial_attacked < MAX_DASHES:
		aerial_attack_sound.play()
		air_wait.start()
		times_aerial_attacked += 1

func get_direction():
	direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	if direction.x != 0.0:
		last_facing_direction = direction
	elif is_on_floor():
		last_facing_direction.y = 0.0

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta * gravity_percent
	else:
		times_dashed = 0
		times_aerial_attacked = 0

func apply_horizontal_movement():
	if not dashing:
		speed = lerp(speed, BASE_SPEED, 0.1)
	
	if direction.x != 0.0:
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, friction)

func _on_dash_timeout_timeout() -> void:
	can_dash = true

func _on_health_component_died() -> void:
	dead = true

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "DeathRight" or anim_name == "DeathLeft":
		print("dead")

func on_killzoned():
	physics_hitbox.disabled = true
	death_timer.wait_time = 1.5
	dead = true

func _on_air_wait_timeout() -> void:
	velocity.y = jump_velocity * 1.3


func _on_pitch_timer_timeout() -> void:
	footstep_sound.pitch_scale = 1.0


func _on_death_timer_timeout() -> void:
	get_tree().reload_current_scene()
