extends RayCast3D
class_name Interactor

## Minimal interactor: casts forward and calls `interact(by)` on hit target if available.

func get_current_target():
	if is_colliding():
		return get_collider()
	return null

func interact() -> void:
	var target = get_current_target()
	if target == null:
		return
	# Direct method contract
	if target.has_method("interact"):
		target.interact(get_owner())
		return
	# Group-based fallback
	if target is Node and (target as Node).is_in_group("interactable"):
		(target as Node).emit_signal.call_deferred("interacted", get_owner())
