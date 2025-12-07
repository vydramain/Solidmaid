extends Node3D
class_name BodyComponent

## Instantiates a PackedScene containing the visual mesh/rig for the character.
@export var body_scene: PackedScene:
	set(value):
		body_scene = value
		_spawn_body()

var _current_body: Node3D


func _ready():
	_spawn_body()


func _spawn_body() -> void:
	if _current_body:
		_current_body.queue_free()
		_current_body = null
	if body_scene == null:
		return

	var instance := body_scene.instantiate()
	if not (instance is Node3D):
		instance.queue_free()
		push_error("BodyComponent expects a Node3D PackedScene")
		return

	add_child(instance)
	_current_body = instance
