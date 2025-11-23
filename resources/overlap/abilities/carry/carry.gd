extends Node
class_name CarrySlots

## Manages character-held slots and uses an aim node (look pivot) for throw direction.

const SLOT_RIGHT := "right"
const SLOT_LEFT := "left"
const _DEFAULT_ORDER := [SLOT_RIGHT, SLOT_LEFT]
const AFFORDANCE_CONTAINER := "Affordances"
const AFFORDANCE_CARRIABLE := &"carriable"
const AFFORDANCE_THROWABLE := &"throwable"
const Affordance := preload("uid://dmt7xvvxqcc4i")

@export var default_active_slot := SLOT_RIGHT
@export_range(5.0, 40.0, 0.5, "suffix:m/s") var throw_speed: float = 18.0
@export_range(0.0, 12.0, 0.1, "suffix:m/s") var throw_upward_boost: float = 4.5
@export_range(0.1, 3.0, 0.05, "suffix:s") var throw_cooldown_seconds: float = 0.8

var active_slot: String
var _slot_items := {
	SLOT_RIGHT: null,
	SLOT_LEFT: null,
}
var _slot_anchors := {
	SLOT_RIGHT: null,
	SLOT_LEFT: null,
}

var _character: Node = null
var _aim_node: Node3D = null
var _cooldown_timer: Timer


func _ready() -> void:
	_character = get_owner()
	active_slot = default_active_slot
	_cooldown_timer = Timer.new()
	_cooldown_timer.one_shot = true
	_cooldown_timer.autostart = false
	add_child(_cooldown_timer)


func attach_to_rig(rig: Node3D) -> void:
	if rig == null:
		_slot_anchors[SLOT_RIGHT] = null
		_slot_anchors[SLOT_LEFT] = null
		return

	_slot_anchors[SLOT_RIGHT] = rig.get_node_or_null("HandSockets/RightHandSlot")
	_slot_anchors[SLOT_LEFT] = rig.get_node_or_null("HandSockets/LeftHandSlot")


func set_aim_node(node: Node3D) -> void:
	_aim_node = node


func has_free_slot() -> bool:
	return _slot_items[SLOT_RIGHT] == null or _slot_items[SLOT_LEFT] == null


func try_pickup(item: Node3D, preferred_slot: String = "") -> bool:
	if item == null:
		return false
	if not _is_item_carriable(item):
		return false
	
	var order: Array = []
	if preferred_slot in _DEFAULT_ORDER:
		order.append(preferred_slot)
	for slot_name in _DEFAULT_ORDER:
		if slot_name != preferred_slot:
			order.append(slot_name)
	
	for slot_name in order:
		if _slot_items[slot_name] == null:
			return _attach_item(slot_name, item)
	return false


func try_drop(preferred_slot: String = "") -> Node3D:
	var order: Array = []
	if preferred_slot in _DEFAULT_ORDER:
		order.append(preferred_slot)
	for slot_name in _DEFAULT_ORDER:
		if slot_name != preferred_slot:
			order.append(slot_name)

	for slot_name in order:
		var item: Node3D = _slot_items.get(slot_name, null)
		if item != null:
			_detach_item(slot_name, item, Vector3.ZERO)
			return item
	return null


func request_throw(slot_name: String = "") -> bool:
	if _cooldown_timer.is_stopped() == false:
		return false

	var slot := slot_name if slot_name in _slot_items else active_slot
	var item: Node3D = _slot_items.get(slot, null)
	if item == null:
		return false
	if not _is_item_throwable(item):
		return false

	var aim_node := _aim_node
	if aim_node == null:
		return false
	var aim_basis: Basis = aim_node.global_transform.basis

	var anchor: Node3D = _slot_anchors.get(slot, null)
	if anchor == null:
		return false

	var forward: Vector3 = -aim_basis.z
	if forward.length_squared() <= 0.001:
		return false
	forward = forward.normalized()

	var release_velocity := forward * throw_speed + Vector3.UP * throw_upward_boost

	_detach_item(slot, item, release_velocity)
	_cooldown_timer.start(throw_cooldown_seconds)
	return true


func is_throw_ready() -> bool:
	return _cooldown_timer.is_stopped()


func get_item(slot_name: String) -> Node3D:
	return _slot_items.get(slot_name, null)


func _attach_item(slot_name: String, item: Node3D) -> bool:
	var anchor: Node3D = _slot_anchors.get(slot_name, null)
	if anchor == null:
		Custom_Logger.warning(self, "Cannot attach to slot '%s': anchor missing" % slot_name)
		return false
	
	var previous_parent := item.get_parent()
	var anchor_tx := anchor.global_transform
	if previous_parent:
		previous_parent.remove_child(item)
	anchor.add_child(item)
	item.global_transform = anchor_tx
	
	_notify_pickup_hooks(item, slot_name)
	
	_slot_items[slot_name] = item
	return true


func _detach_item(slot_name: String, item: Node3D, release_velocity: Vector3) -> void:
	var anchor: Node3D = _slot_anchors.get(slot_name, null)
	var world_parent: Node = _character.get_parent() if _character else get_tree().current_scene
	var release_transform: Transform3D = anchor.global_transform if anchor else item.global_transform

	if item.get_parent():
		item.get_parent().remove_child(item)
	if world_parent:
		world_parent.add_child(item)
	item.global_transform = release_transform
	_notify_release_hooks(item, release_velocity)

	_slot_items[slot_name] = null


func _is_item_carriable(item: Node) -> bool:
	if item == null:
		return false
	if item.has_method("has_affordance"):
		return item.has_affordance(AFFORDANCE_CARRIABLE)
	return _item_has_child_affordance(item, AFFORDANCE_CARRIABLE)


func _is_item_throwable(item: Node) -> bool:
	if item == null:
		return false
	if item.has_method("has_affordance"):
		return item.has_affordance(AFFORDANCE_THROWABLE)
	return _item_has_child_affordance(item, AFFORDANCE_THROWABLE)


func _item_has_child_affordance(item: Node, input_name: StringName) -> bool:
	var aff_root: Node = item.get_node_or_null(AFFORDANCE_CONTAINER)
	if aff_root == null:
		return false
	for child in aff_root.get_children():
		if child is Affordance and child.provides(input_name):
			return true
	return false


func _notify_pickup_hooks(item: Node, slot_name: String) -> void:
	var handled := _call_affordance_method(item, "on_picked_up", [self, slot_name])
	if not handled and item.has_method("on_picked_up"):
		item.on_picked_up(self, slot_name)


func _notify_release_hooks(item: Node, release_velocity: Vector3) -> void:
	var handled := _call_affordance_method(item, "on_released", [release_velocity])
	if not handled and item.has_method("on_released"):
		item.on_released(release_velocity)


func _call_affordance_method(item: Node, method: StringName, args: Array) -> bool:
	var aff_root: Node = item.get_node_or_null(AFFORDANCE_CONTAINER)
	if aff_root == null:
		return false
	var invoked := false
	for child in aff_root.get_children():
		if child.has_method(method):
			child.callv(method, args)
			invoked = true
	return invoked
