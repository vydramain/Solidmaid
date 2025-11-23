extends RayCast3D
class_name Interactor

## Minimal interactor: casts forward and calls `interact(by)` on hit target if available.

signal target_changed(target)

var _current_target


func _ready() -> void:
	set_physics_process(true)
	update_target_state(get_current_target())


func _physics_process(_dt: float) -> void:
	update_target_state(get_current_target())


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


func update_target_state(new_target) -> void:
	if new_target == _current_target:
		return
	_current_target = new_target
	target_changed.emit(_current_target)
