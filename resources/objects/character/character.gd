extends "res://resources/overlap/locomotion/locomotion.gd"

const CAMERA_RIG_NODE_NAME := "CameraRig"

@export var camera_rig_scene: PackedScene

var body := self
@onready var health := $"Vitality"
@onready var abilities := $"Abilities"
@onready var interactor := $"Interactor"
@onready var controller_slot := $"ControllerSlot"

var camera_rig: Node3D
var camera: Camera3D


func _ready():
	super._ready()
	health.died.connect(_on_died)
	if controller_slot.controller_scene:
		attach_controller(controller_slot.controller_scene)

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


func ensure_camera_rig() -> Node3D:
	if camera_rig and camera_rig.is_inside_tree():
		return camera_rig

	if not camera_rig_scene:
		return null

	var existing := get_node_or_null(CAMERA_RIG_NODE_NAME)
	if existing and existing != camera_rig:
		existing.queue_free()

	camera_rig = camera_rig_scene.instantiate()
	camera_rig.name = CAMERA_RIG_NODE_NAME
	add_child(camera_rig)
	_update_camera_reference()
	refresh_look_pivot()
	return camera_rig


func get_camera() -> Camera3D:
	return camera


func _update_camera_reference():
	if not camera_rig:
		camera = null
		return

	camera = camera_rig.get_node_or_null("Camera3D")
