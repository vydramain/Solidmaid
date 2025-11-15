extends Locomotion

signal interactor_ready(interactor)

const VISION_RIG_NODE_NAME := "VisionRig"

var body := self
@onready var carry_slots: CarrySlots = $"CarrySlots"
@onready var health: Vitality = $"Vitality"
@onready var abilities: Node = $"Abilities"
@onready var controller_slot: ControllerSlot = $"ControllerSlot"

var vision_rig: Node3D
var vision_camera: Camera3D
var interactor: Interactor


func _ready():
	super._ready()
	health.died.connect(_on_died)
	ensure_vision_rig()
	if controller_slot.controller_scene:
		attach_controller(controller_slot.controller_scene)
	_update_carry_slots_aim()


func attach_controller(controller_scene: PackedScene):
	controller_slot.get_children().map(func(input_controller): input_controller.queue_free())
	var c = controller_scene.instantiate()
	controller_slot.add_child(c)
	c.init(self)

func get_ability(ability_name: String):
	return abilities.get_node_or_null(ability_name)


func _on_died():
	for a in abilities.get_children():
		if a.has_method("request_stop"):
			a.request_stop()
	controller_slot.process_mode = Node.PROCESS_MODE_DISABLED


func ensure_vision_rig() -> Node3D:
	if vision_rig and vision_rig.is_inside_tree():
		return vision_rig
	
	var found := find_child(VISION_RIG_NODE_NAME, true, false)
	if found and found is Node3D:
		_set_vision_rig(found)
		return vision_rig
	
	return null

func get_vision_camera() -> Camera3D:
	return vision_camera


func _update_vision_reference():
	if not vision_rig:
		vision_camera = null
		set_look_pivot_node(self)
		return

	var look_pivot_node := vision_rig.get_node_or_null("LookPivot")
	if look_pivot_node and look_pivot_node is Node3D:
		set_look_pivot_node(look_pivot_node)
	else:
		set_look_pivot_node(self)
	look_pivot_node = look_pivot_node if look_pivot_node is Node3D else null
	vision_camera = look_pivot_node.get_node_or_null("Camera3D") if look_pivot_node else vision_rig.get_node_or_null("LookPivot/Camera3D")
	_update_camera_current_flag()
	_update_carry_slots_aim()


func get_carry_slots() -> CarrySlots:
	return carry_slots

func get_interactor() -> Interactor:
	return interactor

func pickup_holdable(item: Node3D, preferred_slot: String = "") -> bool:
	if carry_slots == null:
		return false
	return carry_slots.try_pickup(item, preferred_slot)

func request_throw(slot_name: String = "") -> bool:
	if carry_slots == null:
		return false
	return carry_slots.request_throw(slot_name)

func refresh_look_pivot():
	if vision_rig:
		var look_pivot_node := vision_rig.get_node_or_null("LookPivot")
		if look_pivot_node and look_pivot_node is Node3D:
			set_look_pivot_node(look_pivot_node)
		else:
			set_look_pivot_node(self)
	else:
		super.refresh_look_pivot()
	_update_carry_slots_aim()


func _update_carry_slots_aim():
	if carry_slots:
		carry_slots.set_aim_node(get_look_pivot())


func register_ability_dependency(node: Node) -> void:
	if node is Interactor:
		interactor = node
		interactor_ready.emit(interactor)
	elif node is Node3D and node.name == VISION_RIG_NODE_NAME:
		_set_vision_rig(node)
	_attach_interactor_to_pivot()


func _set_vision_rig(node: Node3D) -> void:
	if not node:
		return
	vision_rig = node
	if carry_slots:
		carry_slots.attach_to_rig(vision_rig)
	_update_vision_reference()

func _update_camera_current_flag() -> void:
	if not vision_camera:
		return
	if controller_slot and controller_slot.controller_kind == 2:
		vision_camera.current = true
	else:
		vision_camera.current = false

func _attach_interactor_to_pivot() -> void:
	if interactor == null:
		return
	var pivot := get_look_pivot()
	if pivot == null or interactor.get_parent() == pivot:
		return
	if interactor.get_parent():
		interactor.get_parent().remove_child(interactor)
	pivot.add_child(interactor)
	interactor.transform = Transform3D.IDENTITY
