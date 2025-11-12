extends Node
class_name ControllerSlot

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
