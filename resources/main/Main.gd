extends Node

@export var initial_level_scene: PackedScene = preload(Resource_Registry.LEVELS["SANDBOX"])

@onready var level_container = $LevelContainer

@onready var current_scene = $CurrentScene

var current_level: Node = null

func _ready() -> void:
	if initial_level_scene:
		load_level(initial_level_scene)
	else:
		Custom_Logger.error(self, "No initial level assigned! Cannot proceed with level loading.")


func load_level(scene: PackedScene) -> void:
	if current_level and current_level.is_inside_tree():
		current_level.queue_free()
		current_level = null
	
	if not scene:
		Custom_Logger.error(self, "Attempted to load a null scene. Aborting load.")
		return
	
	current_level = scene.instantiate()
	if not current_level:
		Custom_Logger.error(self, "Failed to instantiate scene: '%s'" % scene.resource_path)
		return
	
	level_container.add_child(current_level)
	Custom_Logger.log(self, "Level '%s' successfully loaded and added to LevelContainer." % current_level.name)
