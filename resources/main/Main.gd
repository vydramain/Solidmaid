extends Node2D

@export var initial_level_scene: PackedScene = preload("res://resources/levels/home/Home_Level.tscn")

@onready var level_container = $LevelContainer
@onready var current_scene = $CurrentScene

var current_level: Node = null

func _ready() -> void:
	Custom_Logger.log(self, "Main node ready. Attempting to load initial level...")
	if initial_level_scene:
		load_level(initial_level_scene)
	else:
		Custom_Logger.log(self, "No initial level assigned! Cannot proceed with level loading.")


func load_level(scene: PackedScene) -> void:
	# Clean up the previous level if it exists
	if current_level and current_level.is_inside_tree():
		Custom_Logger.log(self, "Cleaning up previous level: '%s'" % current_level.name)
		current_level.queue_free()
		current_level = null
	
	if not scene:
		Custom_Logger.log(self, "Attempted to load a null scene. Aborting load.")
		return
	
	Custom_Logger.log(self, "Instantiating new level from scene: '%s'" % scene.resource_path)
	
	# Instance the new level and add it to the container
	current_level = scene.instantiate()
	if not current_level:
		Custom_Logger.log(self, "Failed to instantiate scene: '%s'" % scene.resource_path)
		return
	
	level_container.add_child(current_level)
	Custom_Logger.log(self, "Level '%s' successfully loaded and added to LevelContainer." % current_level.name)
