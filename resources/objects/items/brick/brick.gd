extends RigidBody3D
class_name BrickItem

enum BrickState {
	GROUNDED,
	HELD,
	THROWN,
}

@export_range(0.0, 2.0, 0.05, "suffix:s") var pickup_delay: float = 0.2
@export var held_local_position: Vector3 = Vector3(0.15, -0.2, -0.35)
@export var held_local_rotation_degrees: Vector3 = Vector3(-10.0, 90.0, 0.0)

var state: BrickState = BrickState.GROUNDED
var _last_release_time: float = -1.0
var _cached_layer: int
var _cached_mask: int


func _ready() -> void:
	_cached_layer = collision_layer
	_cached_mask = collision_mask
	contact_monitor = true
	max_contacts_reported = 4


func _physics_process(_dt: float) -> void:
	if state == BrickState.THROWN and sleeping:
		state = BrickState.GROUNDED


func interact(by) -> void:
	if not _can_be_picked_up():
		return
	if by and by.has_method("pickup_holdable"):
		var did_pickup: bool = by.pickup_holdable(self)
		if did_pickup:
			Custom_Logger.debug(self, "Brick picked up by %s" % by.name)


func on_picked_up(_slots: CarrySlots, _slot_name: String) -> void:
	state = BrickState.HELD
	freeze = true
	sleeping = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	_collision_disable()
	apply_held_transform()


func on_released(release_velocity: Vector3) -> void:
	var speed := release_velocity.length()
	state = BrickState.THROWN if speed > 0.1 else BrickState.GROUNDED
	_last_release_time = Time.get_ticks_msec() / 1000.0
	freeze = false
	sleeping = false
	_collision_restore()
	if speed > 0.0:
		linear_velocity = release_velocity
	else:
		linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO


func apply_held_transform() -> void:
	var basis := Basis()
	basis = basis.rotated(Vector3.RIGHT, deg_to_rad(held_local_rotation_degrees.x))
	basis = basis.rotated(Vector3.UP, deg_to_rad(held_local_rotation_degrees.y))
	basis = basis.rotated(Vector3.FORWARD, deg_to_rad(held_local_rotation_degrees.z))
	transform = Transform3D(basis, held_local_position)


func _can_be_picked_up() -> bool:
	if state == BrickState.HELD:
		return false
	var now := Time.get_ticks_msec() / 1000.0
	if _last_release_time < 0:
		return true
	return (now - _last_release_time) >= pickup_delay


func _collision_disable() -> void:
	collision_layer = 0
	collision_mask = 0


func _collision_restore() -> void:
	collision_layer = _cached_layer
	collision_mask = _cached_mask
