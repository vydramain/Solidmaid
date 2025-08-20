extends Node2D

@export var initial_level_scene: PackedScene = preload("res://resources/levels/home/Home_Level.tscn")

@onready var level_container = $LevelContainer
@onready var current_scene = $CurrentScene

var current_level: Node = null


func _ready() -> void:
	print("[Main] Ready. Loading initial level...")
	if initial_level_scene:
		load_level(initial_level_scene)
	else:
		push_error("[Main] No initial level assigned!")


func load_level(scene: PackedScene) -> void:
	# Clean up old level
	if current_level and current_level.is_inside_tree():
		current_level.queue_free()
		current_level = null
	
	print("[Main] Instantiating new level: ", scene.resource_path)
	
	# Instance and add to container
	current_level = scene.instantiate()
	level_container.add_child(current_level)
