extends Affordance
class_name CarriableAffordance

const NAME_CARRIABLE := &"carriable"

@export var carriable: bool = true

var _cached_layer: int = -1
var _cached_mask: int = -1


func _ready() -> void:
	affordance_name = NAME_CARRIABLE


func provides(provided_name: StringName) -> bool:
	if not carriable:
		return false
	return super.provides(provided_name)


func on_picked_up(_slots: CarrySlots, _slot_name: String) -> void:
	var host := _get_host()
	if host == null:
		return
	_cache_collision(host)
	host.freeze = true
	host.sleeping = true
	host.linear_velocity = Vector3.ZERO
	host.angular_velocity = Vector3.ZERO
	_disable_collision(host)
	_call_host_hook(host, "on_carriable_picked_up", [_slots, _slot_name])


func on_released(release_velocity: Vector3) -> void:
	var host := _get_host()
	if host == null:
		return
	host.freeze = false
	host.sleeping = false
	_restore_collision(host)
	host.linear_velocity = release_velocity
	host.angular_velocity = Vector3.ZERO
	_call_host_hook(host, "on_carriable_released", [release_velocity])


func _get_host() -> RigidBody3D:
	var affordance_root := get_parent()
	if affordance_root and affordance_root.get_parent() is RigidBody3D:
		return affordance_root.get_parent()
	return null


func _cache_collision(host: RigidBody3D) -> void:
	_cached_layer = host.collision_layer
	_cached_mask = host.collision_mask


func _disable_collision(host: RigidBody3D) -> void:
	host.collision_layer = 0
	host.collision_mask = 0


func _restore_collision(host: RigidBody3D) -> void:
	if _cached_layer >= 0:
		host.collision_layer = _cached_layer
	if _cached_mask >= 0:
		host.collision_mask = _cached_mask


func _call_host_hook(host: Node, method: StringName, args: Array) -> void:
	if host.has_method(method):
		host.callv(method, args)
