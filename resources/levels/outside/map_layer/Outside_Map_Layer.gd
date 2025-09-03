extends Node2D

# Preload environment scenes
var GrassScene := preload("res://resources/entity/environment/grass/Grass.tscn")
var TreeEntityScene := preload("res://resources/entity/environment/trees/Tree.tscn")

# TileMap references
@onready var background_scene: TileMapLayer = $Background
@onready var decorations_scene: TileMapLayer = $Decorations
@onready var environment_scene: TileMapLayer = $Environment

# Preload scripts for chunk drawing and entity spawning
@onready var upper_drawer = Outside_Upper_Chunk_Drawer.new()
@onready var lower_drawer = Outside_Lower_Chunk_Drawer.new()
@onready var entity_spawner = Outside_Entity_Spawner.new()

func _ready() -> void:
	Logger.log(self, "[ChunkManager] Initialization started")
	
	# Add child nodes
	add_child(upper_drawer)
	Logger.log(self, "[ChunkManager] Upper chunk drawer added as child")

	add_child(lower_drawer)
	Logger.log(self, "[ChunkManager] Lower chunk drawer added as child")

	add_child(entity_spawner)
	Logger.log(self, "[ChunkManager] Entity spawner added as child")
	
	# Assign backgrounds to chunk drawers
	upper_drawer.background_scene = background_scene
	lower_drawer.background_scene = background_scene
	Logger.log(self, "[ChunkManager] Background TileMap assigned to upper and lower drawers")
	
	# Draw init chunks
	upper_drawer.draw_upper_chunk(upper_drawer.background_scene, Outside_Constants.UPPER_CHUNK.LIGTH_BUILDING, 0)
	lower_drawer.draw_lower_chunk(lower_drawer.background_scene, Outside_Constants.LOWER_CHUNK.GRASS, 0)
	upper_drawer.draw_upper_chunk(upper_drawer.background_scene, Outside_Constants.UPPER_CHUNK.LIGTH_BUILDING, 1)
	lower_drawer.draw_lower_chunk(lower_drawer.background_scene, Outside_Constants.LOWER_CHUNK.GRASS, 1)
	
	# Draw all chunks
	_draw_chunks(Outside_Constants.MAX_CHUNKS)
	
	Logger.log(self, "[ChunkManager] Finished drawing all chunks. Total chunks drawn: %d" % Outside_Constants.MAX_CHUNKS)

func _draw_chunks(chunks_amount: int) -> void:
	var upper_type_index = randi() % Outside_Constants.UPPER_CHUNK.size()
	var lower_type_index = randi() % Outside_Constants.LOWER_CHUNK.size()
	
	var current_upper_chunk_type = Outside_Constants.UPPER_CHUNK.LIGTH_BUILDING
	var current_lower_chunk_type = Outside_Constants.LOWER_CHUNK.GRASS
	
	for i in range(2, chunks_amount):
		var start_x = i * Outside_Constants.CHUNK_TILE_WIDTH
		
		Logger.log(self, "[ChunkManager] Drawing chunk %d at X=%d | Upper type index=%d, Lower type index=%d" % [i, start_x, upper_type_index, lower_type_index])
		
		var array_of_possible_lower_chunks = Outside_Constants.POSSIBLE_NEXT_CHUNK_BASED_ON_PREVIOUS.get(current_lower_chunk_type)
		current_lower_chunk_type = array_of_possible_lower_chunks[randi() % array_of_possible_lower_chunks.size()]
		
		var array_of_possible_upper_chunks = Outside_Constants.POSSIBLE_NEXT_CHUNK_BASED_ON_PREVIOUS.get(current_upper_chunk_type)
		current_upper_chunk_type = array_of_possible_upper_chunks[randi() % array_of_possible_upper_chunks.size()]
		
		# Draw upper and lower chunks
		upper_drawer.draw_upper_chunk(upper_drawer.background_scene, current_upper_chunk_type, i)
		lower_drawer.draw_lower_chunk(lower_drawer.background_scene, current_lower_chunk_type, i)
		
		Logger.log(self, "[ChunkManager] Chunk %d drawn successfully" % i)
