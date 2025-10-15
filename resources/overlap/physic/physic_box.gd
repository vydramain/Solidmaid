extends RigidBody2D
@export var speed: float = 30.
@export var accel: float = 125.
@export var friction: float = 600.

func _on_body_entered(body: Node) -> void:
	if body is RigidBody2D or body is CharacterBody2D:
		var rel_vel = (linear_velocity - body.linear_velocity).length()
		var damage = 0.5 * get_mass() * rel_vel * rel_vel * 0.001
		if body.has_method("receive_damage"):
			body.receive_damage(100)

func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body is RigidBody2D or body is CharacterBody2D:
		var rel_vel = (linear_velocity - body.linear_velocity).length()
		var damage = 0.5 * get_mass() * rel_vel * rel_vel * 0.001
		if body.has_method("receive_damage"):
			body.receive_damage(100)
