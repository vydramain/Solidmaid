extends Node2D

var GrassScene := preload("res://resources/entity/environment/grass/Grass.tscn")
var TreeEntityScene := preload("res://resources/entity/environment/trees/Tree.tscn")

# TileMap references
@onready var background_scene: TileMapLayer = $Background
@onready var decorations_scene: TileMapLayer = $Decorations
@onready var environment_scene: TileMapLayer = $Environment

# Preload scripts
@onready var upper_drawer = Outside_Upper_Chunk_Drawer.new()
@onready var lower_drawer = Outside_Lower_Chunk_Drawer.new()
@onready var entity_spawner = Outside_Entity_Spawner.new()

func _ready() -> void:
	Logger.log(self, "ChunkManager ready")
	
	# Add children
	add_child(upper_drawer)
	add_child(lower_drawer)
	add_child(entity_spawner)
	
	# Assign backgrounds
	upper_drawer.background_scene = background_scene
	lower_drawer.background_scene = background_scene
	
	# Draw chunks
	for i in range(Outside_Constants.MAX_CHUNKS):
		_draw_chunk(i)

func _draw_chunk(index: int) -> void:
	var upper_type = randi() % Outside_Constants.UPPER_CHUNK.size()
	var lower_type = randi() % Outside_Constants.LOWER_CHUNK.size()
	
	var start_x = index * Outside_Constants.CHUNK_TILE_WIDTH
	
	upper_drawer.draw_upper_chunk(upper_drawer.background_scene, start_x, 0)
	lower_drawer.draw_lower_chunk(lower_drawer.background_scene, start_x, 0)
