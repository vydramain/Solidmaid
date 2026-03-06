extends Node
class_name ControllerSlot

var _character: Character = null

@export_enum("None", "AI", "Player")
var controller_kind := 0

const SCENE_AI := preload("uid://qxrjpanwyptq")
const SCENE_PLAYER := preload("uid://btxiq1qykgkxl")

var controller_scene: PackedScene:
	get:
		match controller_kind:
			1: return SCENE_AI
			2: return SCENE_PLAYER
			_: return null


func _rebuild_controller() -> void:
	get_children().map(func(child): child.free_queue())
	if _character and controller_scene:
		var controller = controller_scene.instantiate()
		add_child(controller)
		controller.init(_character)


func attach_to_character(character: Character) -> void:
	_character = character
	_rebuild_controller()
