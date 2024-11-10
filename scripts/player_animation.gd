extends AnimationTree

@onready var animation_tree: AnimationTree = $"."
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var player: Player = get_owner()

var last_facing_direction = Vector2.ZERO

func _process(delta: float) -> void:
	animation_tree.call_deferred("set", "parameters/Idle/TimeScale/scale", 0.5)
	animation_tree.call_deferred("set", "parameters/Moving/TimeScale/scale", 1.5)
	animation_tree.call_deferred("set", "parameters/Dash/TimeScale/scale", 1.5)
	animation_tree.call_deferred("set", "parameters/AerialAttack/AerialAttack/TimeScale/scale", 1.5)
	if player.direction.x != 0:
		last_facing_direction = player.velocity.normalized()
	animation_tree.call_deferred("set", "parameters/Moving/MovingBlend/blend_position", last_facing_direction.x)
	animation_tree.call_deferred("set", "parameters/Idle/IdleBlend/blend_position", last_facing_direction.x)
	animation_tree.call_deferred("set", "parameters/Jump/StartJump/blend_position", last_facing_direction.x)
	animation_tree.call_deferred("set", "parameters/Jump/Jumping/blend_position", last_facing_direction.x)
	animation_tree.call_deferred("set", "parameters/Jump/Falling/blend_position", last_facing_direction.x)
	animation_tree.call_deferred("set", "parameters/Jump/EndJump/blend_position", last_facing_direction.x)
	animation_tree.call_deferred("set", "parameters/Death/DeathBlend/blend_position", last_facing_direction.x)
	if player.attack_state != player.Attacks.IDLE:
		animation_tree.set("parameters/BasicAttack/BasicAttackBlend/blend_position", last_facing_direction.x)
		animation_tree.set("parameters/UppercutAttack/StartUppercut/blend_position", last_facing_direction.x)
		animation_tree.set("parameters/UppercutAttack/JumpingUppercut/blend_position", last_facing_direction.x)
		animation_tree.set("parameters/UppercutAttack/FallingUppercut/blend_position", last_facing_direction.x)
		animation_tree.set("parameters/UppercutAttack/EndUppercut/blend_position", last_facing_direction.x)
		animation_tree.set("parameters/AerialAttack/AerialAttack/AerialAttackBlend/blend_position", last_facing_direction.x)
		animation_tree.set("parameters/AerialAttack/Falling/blend_position", last_facing_direction.x)
	if player.dash_timeout.is_stopped():
		animation_tree.set("parameters/Dash/DashBlend/blend_position", last_facing_direction.x)
