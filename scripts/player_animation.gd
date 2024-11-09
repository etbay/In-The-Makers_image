extends AnimationTree

@onready var animation_tree: AnimationTree = $"."
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var player: Player = get_owner()

var last_facing_direction = Vector2.ZERO

func _process(delta: float) -> void:
	if player.direction.x != 0:
		last_facing_direction = player.velocity.normalized()
	animation_tree.set("parameters/Moving/MovingBlend/blend_position", last_facing_direction.x)
	animation_tree.set("parameters/Idle/IdleBlend/blend_position", last_facing_direction.x)
	animation_tree.set("parameters/Jump/StartJump/blend_position", last_facing_direction.x)
	animation_tree.set("parameters/Jump/Jumping/blend_position", last_facing_direction.x)
	animation_tree.set("parameters/Jump/Falling/blend_position", last_facing_direction.x)
	animation_tree.set("parameters/Jump/EndJump/blend_position", last_facing_direction.x)
	if player.attack_state != player.Attacks.IDLE:
		animation_tree.set("parameters/BasicAttack/BasicAttackBlend/blend_position", last_facing_direction.x)
	if player.dash_timeout.is_stopped():
		animation_tree.set("parameters/Dash/DashBlend/blend_position", last_facing_direction.x)
