extends Node
class_name CarrySlots

## Manages character-held slots and uses an aim node (look pivot) for throw direction.

const SLOT_RIGHT := "right"
const SLOT_LEFT := "left"
const _DEFAULT_ORDER := [SLOT_RIGHT, SLOT_LEFT]
const AFFORDANCE_CONTAINER := "Affordances"
const AFFORDANCE_CARRIABLE := &"carriable"
const AFFORDANCE_THROWABLE := &"throwable"

const AffordanceClass := preload("uid://dmt7xvvxqcc4i")

@export_range(5.0, 40.0, 0.5, "suffix:m/s") var throw_speed: float = 18.0
@export_range(0.0, 12.0, 0.1, "suffix:m/s") var throw_upward_boost: float = 4.5
@export_range(0.1, 3.0, 0.05, "suffix:s") var throw_cooldown_seconds: float = 0.8

@export_node_path("Node3D") var right_slot_path: NodePath = NodePath("")
@export_node_path("Node3D") var left_slot_path: NodePath = NodePath("")

@export var default_active_slot := SLOT_RIGHT
@export var right_slot_tag: String = "RightHandSlot"
@export var left_slot_tag: String = "LeftHandSlot"

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
		push_error("CarrySlots: rig is null, cannot resolve hand anchors.")
		assert(false, "CarrySlots: rig missing; cannot attach.")
		return

	_slot_anchors[SLOT_RIGHT] = resolve_anchor(rig, right_slot_path, right_slot_tag)
	_slot_anchors[SLOT_LEFT] = resolve_anchor(rig, left_slot_path, left_slot_tag)

	var missing: Array[String] = []
	if _slot_anchors[SLOT_RIGHT] == null:
		missing.append("right")
	if _slot_anchors[SLOT_LEFT] == null:
		missing.append("left")
	if missing.size() > 0:
		var message := "CarrySlots: missing hand anchor(s): %s. Check VisionRig setup or tags." % ", ".join(missing)
		push_error(message)
		assert(false, message)


func set_aim_node(node: Node3D) -> void:
	_aim_node = node


func has_free_slot() -> bool:
	return _slot_items[SLOT_RIGHT] == null or _slot_items[SLOT_LEFT] == null


func try_pickup(item: Node3D, preferred_slot: String = "") -> bool:
	if item == null:
		return false
	if not is_item_carriable(item):
		return false
	
	var order: Array = []
	if preferred_slot in _DEFAULT_ORDER:
		order.append(preferred_slot)
	for slot_name in _DEFAULT_ORDER:
		if slot_name != preferred_slot:
			order.append(slot_name)
	
	for slot_name in order:
		if _slot_items[slot_name] == null:
			return attach_item_internal(slot_name, item)
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
			detach_item_internal(slot_name, item, Vector3.ZERO)
			return item
	return null


func request_throw(slot_name: String = "") -> bool:
	if _cooldown_timer.is_stopped() == false:
		return false

	var slot := slot_name if slot_name in _slot_items else active_slot
	var item: Node3D = _slot_items.get(slot, null)
	if item == null:
		return false
	if not is_item_throwable(item):
		return false

	var aim_node := _aim_node
	if aim_node == null:
		return false
	var aim_basis: Basis = aim_node.global_transform.basis

	var anchor: Node3D = _slot_anchors.get(slot, null)
	if anchor == null:
		var message := "CarrySlots: cannot throw from slot '%s' — anchor missing." % slot
		push_error(message)
		assert(false, message)
		return false

	var forward: Vector3 = -aim_basis.z
	if forward.length_squared() <= 0.001:
		return false
	forward = forward.normalized()

	var release_velocity := forward * throw_speed + Vector3.UP * throw_upward_boost

	detach_item_internal(slot, item, release_velocity)
	_cooldown_timer.start(throw_cooldown_seconds)
	return true


func is_throw_ready() -> bool:
	return _cooldown_timer.is_stopped()


func get_item(slot_name: String) -> Node3D:
	return _slot_items.get(slot_name, null)


func attach_item_internal(slot_name: String, item: Node3D) -> bool:
	var anchor: Node3D = _slot_anchors.get(slot_name, null)
	if anchor == null:
		var message := "CarrySlots: cannot attach to slot '%s' — anchor missing." % slot_name
		push_error(message)
		assert(false, message)
		return false
	
	var previous_parent := item.get_parent()
	var anchor_tx := anchor.global_transform
	if previous_parent:
		previous_parent.remove_child(item)
	anchor.add_child(item)
	item.global_transform = anchor_tx
	
	notify_pickup_hooks(item, slot_name)
	
	_slot_items[slot_name] = item
	return true


func detach_item_internal(slot_name: String, item: Node3D, release_velocity: Vector3) -> void:
	var anchor: Node3D = _slot_anchors.get(slot_name, null)
	if anchor == null:
		var message := "CarrySlots: cannot detach from slot '%s' — anchor missing." % slot_name
		push_error(message)
		assert(false, message)
		return
	var world_parent: Node = _character.get_parent() if _character else get_tree().current_scene
	var release_transform: Transform3D = anchor.global_transform

	if item.get_parent():
		item.get_parent().remove_child(item)
	if world_parent:
		world_parent.add_child(item)
	item.global_transform = release_transform
	notify_release_hooks(item, release_velocity)

	_slot_items[slot_name] = null


func is_item_carriable(item: Node) -> bool:
	if item == null:
		return false
	if item.has_method("has_affordance"):
		return item.has_affordance(AFFORDANCE_CARRIABLE)
	return item_has_child_affordance(item, AFFORDANCE_CARRIABLE)


func is_item_throwable(item: Node) -> bool:
	if item == null:
		return false
	if item.has_method("has_affordance"):
		return item.has_affordance(AFFORDANCE_THROWABLE)
	return item_has_child_affordance(item, AFFORDANCE_THROWABLE)


func item_has_child_affordance(item: Node, input_name: StringName) -> bool:
	var aff_root: Node = item.get_node_or_null(AFFORDANCE_CONTAINER)
	if aff_root == null:
		return false
	for child in aff_root.get_children():
		if child is AffordanceClass and child.provides(input_name):
			return true
	return false


func notify_pickup_hooks(item: Node, slot_name: String) -> void:
	var handled := call_affordance_method(item, "on_picked_up", [self, slot_name])
	if not handled and item.has_method("on_picked_up"):
		item.on_picked_up(self, slot_name)


func notify_release_hooks(item: Node, release_velocity: Vector3) -> void:
	var handled := call_affordance_method(item, "on_released", [release_velocity])
	if not handled and item.has_method("on_released"):
		item.on_released(release_velocity)


func call_affordance_method(item: Node, method: StringName, args: Array) -> bool:
	var aff_root: Node = item.get_node_or_null(AFFORDANCE_CONTAINER)
	if aff_root == null:
		return false
	var invoked := false
	for child in aff_root.get_children():
		if child.has_method(method):
			child.callv(method, args)
			invoked = true
	return invoked


func resolve_anchor(rig: Node3D, path: NodePath, tag: String) -> Node3D:
	if path != NodePath("") and rig.has_node(path):
		var found := rig.get_node_or_null(path)
		if found is Node3D:
			return found

	if tag != "":
		var by_name := rig.find_child(tag, true, false)
		if by_name is Node3D:
			return by_name

	var by_group := find_child_by_group(rig, tag)
	if by_group != null:
		return by_group
	return null


func find_child_by_group(root: Node, group: String) -> Node3D:
	if group == "":
		return null
	for child in root.get_children():
		if child is Node3D and child.is_in_group(group):
			return child
		var nested := find_child_by_group(child, group)
		if nested != null:
			return nested
	return null
