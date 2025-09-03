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
@onready var lower_decorations_drawer = Outside_Lower_Decorations_Drawer.new()
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
	
	add_child(lower_decorations_drawer)
	Logger.log(self, "[ChunkManager] Entity spawner added as child")
	
	# Assign backgrounds to chunk drawers
	upper_drawer.background_scene = background_scene
	lower_drawer.background_scene = background_scene
	lower_decorations_drawer.decorations_scene = decorations_scene
	Logger.log(self, "[ChunkManager] Background TileMap assigned to upper and lower drawers")
	
	# Draw init chunks
	lower_drawer.draw_lower_chunk(Outside_Constants.LOWER_CHUNK.GRASS, 0)
	lower_drawer.draw_lower_chunk(Outside_Constants.LOWER_CHUNK.GRASS, 1)
	upper_drawer.draw_upper_chunk(Outside_Constants.UPPER_CHUNK.LIGTH_BUILDING, 0)
	upper_drawer.draw_upper_chunk(Outside_Constants.UPPER_CHUNK.LIGTH_BUILDING, 1)
	
	# Draw decorations
	lower_decorations_drawer.draw_lower_decorations(Outside_Constants.LOWER_CHUNK.GRASS, 0)
	lower_decorations_drawer.draw_lower_decorations(Outside_Constants.LOWER_CHUNK.GRASS, 1)
	
	# Draw all chunks
	_draw_chunks(Outside_Constants.MAX_CHUNKS)
	
	Logger.log(self, "[ChunkManager] Finished drawing all chunks. Total chunks drawn: %d" % Outside_Constants.MAX_CHUNKS)

func _draw_chunks(chunks_amount: int) -> void:
	var current_upper_chunk_type = Outside_Constants.UPPER_CHUNK.LIGTH_BUILDING
	var current_lower_chunk_type = Outside_Constants.LOWER_CHUNK.GRASS
	
	for i in range(2, chunks_amount):
		var start_x = i * Outside_Constants.CHUNK_TILE_WIDTH
		
		var array_of_possible_lower_chunks = Outside_Constants.POSSIBLE_NEXT_CHUNK_BASED_ON_PREVIOUS.get(current_lower_chunk_type)
		current_lower_chunk_type = array_of_possible_lower_chunks[randi() % array_of_possible_lower_chunks.size()]
		
		var array_of_possible_upper_chunks = Outside_Constants.POSSIBLE_UPPER_CHUNK_BASED_ON_LOWER.get(current_lower_chunk_type)
		current_upper_chunk_type = array_of_possible_upper_chunks[randi() % array_of_possible_upper_chunks.size()]
		
		Logger.log(self, "[ChunkManager] For lower chunk array_of_possible_upper_chunks" + str(array_of_possible_upper_chunks))
		Logger.log(self, "[ChunkManager] For lower chunk %d choosed type: '%d' choosed upper chunk: '%d'" % [i, current_lower_chunk_type, current_upper_chunk_type])
		
		# Draw upper and lower chunks
		upper_drawer.draw_upper_chunk(current_upper_chunk_type, i)
		lower_drawer.draw_lower_chunk(current_lower_chunk_type, i)
		lower_decorations_drawer.draw_lower_decorations(current_lower_chunk_type, i)
		
		Logger.log(self, "[ChunkManager] Chunk %d drawn successfully" % i)
