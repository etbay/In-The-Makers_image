extends AnimationTree

@onready var animation_tree: AnimationTree = $"."
@onready var toaster: CharacterBody2D = get_owner()
var direction

func _process(delta: float) -> void:
	if not toaster.move_time.is_stopped() and toaster.velocity != Vector2.ZERO:
		direction = toaster.velocity.normalized().x
	animation_tree.call_deferred("set", "parameters/Attack/TimeScale/scale", 1.0)
	animation_tree.call_deferred("set", "parameters/Move/TimeScale/scale", 1.0)
	animation_tree.call_deferred("set", "parameters/Attack/AttackBlend/blend_position", direction)
	animation_tree.call_deferred("set", "parameters/Move/MoveBlend/blend_position", direction)
	animation_tree.call_deferred("set", "parameters/Damaged/blend_position", direction)
