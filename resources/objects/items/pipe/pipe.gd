extends RigidBody3D
class_name PipeItem

enum PipeState {
	GROUNDED,
	HELD,
	THROWN,
}

@export_range(0.0, 2.0, 0.05, "suffix:s") var pickup_delay: float = 0.25

var state: PipeState = PipeState.GROUNDED
var _last_release_time: float = -1.0
var _cached_layer: int
var _cached_mask: int


func _ready() -> void:
	_cached_layer = collision_layer
	_cached_mask = collision_mask
	contact_monitor = true
	max_contacts_reported = 6


func interact(by) -> void:
	if not _can_be_picked_up():
		return
	if by and by.has_method("pickup_holdable"):
		var picked = by.pickup_holdable(self)
		if picked:
			Custom_Logger.debug(self, "Pipe picked up by %s" % by.name)


func on_picked_up(_slots, slot_name: String) -> void:
	state = PipeState.HELD
	freeze = true
	sleeping = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	_collision_disable()


func on_released(release_velocity: Vector3) -> void:
	var speed := release_velocity.length()
	state = PipeState.THROWN if speed > 0.1 else PipeState.GROUNDED
	_last_release_time = Time.get_ticks_msec() / 1000.0
	freeze = false
	sleeping = false
	_collision_restore()
	linear_velocity = release_velocity
	angular_velocity = Vector3.ZERO


func _can_be_picked_up() -> bool:
	if state == PipeState.HELD:
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
