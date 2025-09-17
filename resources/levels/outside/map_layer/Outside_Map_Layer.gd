extends Node2D

# Layer enumeration for Z dimension
enum LAYER {
	BACKGROUND = 0,
	DECORATIONS = 1,
	ENVIRONMENT_1 = 2,
	ENVIRONMENT_2 = 3
}

# TileMap references
@onready var background_scene: TileMapLayer = $Background
@onready var decorations_scene: TileMapLayer = $Decorations
@onready var environment_layer_1_scene: Node = $EnvironmentLayer_1
@onready var environment_layer_2_scene: Node = $EnvironmentLayer_2

# Preload scripts for chunk drawing and entity spawning
@onready var lower_background_drawer = Outside_Lower_Background_Drawer.new()
@onready var lower_decorations_drawer = Outside_Lower_Decorations_Drawer.new()
@onready var lower_environment_drawer = Outside_Lower_Environment_Drawer.new()
@onready var upper_background_drawer = Outside_Upper_Background_Drawer.new()
@onready var upper_environment_drawer = Outside_Upper_Environment_Drawer.new()

# Three-dimensional array: [layer][x][y]
 #layer: 0=background, 1=decorations, 2=environment_1, 3=environment_2
var layer_data: Array[Array] = []

func _ready() -> void:
	Custom_Logger.log(self, "[ChunkManager] Initialization started")
	
	# Initialize the 3D array
	_initialize_layer_data()
	
	# Add child nodes
	add_child(upper_background_drawer)
	add_child(upper_environment_drawer)
	Custom_Logger.log(self, "[ChunkManager] Upper chunk drawers added as child")
	
	add_child(lower_background_drawer)
	add_child(lower_decorations_drawer)
	add_child(lower_environment_drawer)
	Custom_Logger.log(self, "[ChunkManager] Lower chunk drawers added as child")
	
	# Assign references to chunk drawers
	_assign_drawer_references()
	
	# Draw all chunks layer by layer
	_draw_all_chunks_layered(Outside_Constants.MAX_CHUNKS)
	
	# Convert layer data to actual scene nodes
	_apply_layer_data_to_scenes()
	
	Custom_Logger.log(self, "[ChunkManager] Finished drawing all chunks. Total chunks drawn: %d" % Outside_Constants.MAX_CHUNKS)

func _initialize_layer_data() -> void:
	# Initialize 3D array: [4 layers][MAX_CHUNKS * CHUNK_TILE_WIDTH][CHUNK_TILE_HEIGHT]
	var total_width = Outside_Constants.MAX_CHUNKS * Outside_Constants.CHUNK_TILE_WIDTH
	var total_height = Outside_Constants.CHUNK_TILE_HEIGHT
	
	layer_data.resize(4)  # 4 layers
	for layer_idx in range(4):
		layer_data[layer_idx] = []
		layer_data[layer_idx].resize(total_width)
		for x in range(total_width):
			layer_data[layer_idx][x] = []
			layer_data[layer_idx][x].resize(total_height)
			# Initialize with null values
			for y in range(total_height):
				layer_data[layer_idx][x][y] = null
	
	Custom_Logger.log(self, "[ChunkManager] Layer data initialized: %d layers, %dx%d size" % [4, total_width, total_height])

func _assign_drawer_references() -> void:
	lower_background_drawer.layer_data = layer_data
	lower_decorations_drawer.layer_data = layer_data
	lower_environment_drawer.layer_data = layer_data
	upper_background_drawer.layer_data = layer_data
	upper_environment_drawer.layer_data = layer_data
	
	# Assign scene references for final application
	lower_background_drawer.background_scene = background_scene
	lower_decorations_drawer.decorations_scene = decorations_scene
	lower_environment_drawer.environment_layer_1 = environment_layer_1_scene
	lower_environment_drawer.environment_layer_2 = environment_layer_2_scene
	upper_background_drawer.background_scene = background_scene
	upper_environment_drawer.environment_layer_1 = environment_layer_1_scene
	upper_environment_drawer.environment_layer_2 = environment_layer_2_scene
	
	Custom_Logger.log(self, "[ChunkManager] References assigned to all drawers")

func _draw_all_chunks_layered(chunks_amount: int) -> void:
	var current_upper_chunk_type = Outside_Constants.UPPER_CHUNK.LIGTH_BUILDING
	var current_lower_chunk_type = Outside_Constants.LOWER_CHUNK.GRASS
	
	# Draw initial chunks
	_draw_chunk_all_layers(current_lower_chunk_type, current_upper_chunk_type, 0)
	_draw_chunk_all_layers(current_lower_chunk_type, current_upper_chunk_type, 1)
	
	# Draw remaining chunks
	for chunk_idx in range(2, chunks_amount):
		# Determine next chunk types based on previous
		var array_of_possible_lower_chunks = Outside_Constants.POSSIBLE_NEXT_CHUNK_BASED_ON_PREVIOUS.get(current_lower_chunk_type)
		current_lower_chunk_type = array_of_possible_lower_chunks[randi() % array_of_possible_lower_chunks.size()]
		
		var array_of_possible_upper_chunks = Outside_Constants.POSSIBLE_UPPER_CHUNK_BASED_ON_LOWER.get(current_lower_chunk_type)
		current_upper_chunk_type = array_of_possible_upper_chunks[randi() % array_of_possible_upper_chunks.size()]
		
		Custom_Logger.log(self, "[ChunkManager] Chunk %d - Lower: %d, Upper: %d" % [chunk_idx, current_lower_chunk_type, current_upper_chunk_type])
		
		# Draw chunk with all layers
		_draw_chunk_all_layers(current_lower_chunk_type, current_upper_chunk_type, chunk_idx)

func _draw_chunk_all_layers(lower_chunk_type: int, upper_chunk_type: int, chunk_index: int) -> void:
	# Layer 0: Background
	Custom_Logger.log(self, "[ChunkManager] Drawing background layer for chunk %d" % chunk_index)
	lower_background_drawer.draw_lower_chunk_to_layer_data(lower_chunk_type, chunk_index, LAYER.BACKGROUND)
	upper_background_drawer.draw_upper_chunk_to_layer_data(upper_chunk_type, chunk_index, LAYER.BACKGROUND)
	
	# Layer 1: Decorations (based on background layer)
	Custom_Logger.log(self, "[ChunkManager] Drawing decorations layer for chunk %d" % chunk_index)
	lower_decorations_drawer.draw_lower_decorations_to_layer_data(lower_chunk_type, chunk_index, LAYER.DECORATIONS, layer_data[LAYER.BACKGROUND])
	
	# Layer 2: Environment Layer 1 (based on background and decorations)
	Custom_Logger.log(self, "[ChunkManager] Drawing environment layer 1 for chunk %d" % chunk_index)
	var background_context = layer_data[LAYER.BACKGROUND]
	var decorations_context = layer_data[LAYER.DECORATIONS]
	lower_environment_drawer.draw_lower_environment_layer_1_to_layer_data(lower_chunk_type, chunk_index, LAYER.ENVIRONMENT_1, background_context, decorations_context)
	upper_environment_drawer.draw_upper_environment_layer_1_to_layer_data(upper_chunk_type, chunk_index, LAYER.ENVIRONMENT_1, background_context, decorations_context)
	
	# Layer 3: Environment Layer 2 (based on all previous layers)
	Custom_Logger.log(self, "[ChunkManager] Drawing environment layer 2 for chunk %d" % chunk_index)
	var env1_context = layer_data[LAYER.ENVIRONMENT_1]
	lower_environment_drawer.draw_lower_environment_layer_2_to_layer_data(lower_chunk_type, chunk_index, LAYER.ENVIRONMENT_2, background_context, decorations_context, env1_context)
	upper_environment_drawer.draw_upper_environment_layer_2_to_layer_data(upper_chunk_type, chunk_index, LAYER.ENVIRONMENT_2, background_context, decorations_context, env1_context)

func _apply_layer_data_to_scenes() -> void:
	Custom_Logger.log(self, "[ChunkManager] Converting layer data to scene nodes")
	
	# Apply background layer
	_apply_layer_to_tilemap(LAYER.BACKGROUND, background_scene)
	
	# Apply decorations layer
	_apply_layer_to_tilemap(LAYER.DECORATIONS, decorations_scene)
	
	# Apply environment layers
	_apply_layer_to_node(LAYER.ENVIRONMENT_1, environment_layer_1_scene)
	_apply_layer_to_node(LAYER.ENVIRONMENT_2, environment_layer_2_scene)
	
	Custom_Logger.log(self, "[ChunkManager] All layers applied to scenes")

func _apply_layer_to_tilemap(layer_index: int, tilemap: TileMapLayer) -> void:
	var layer = layer_data[layer_index]
	for x in range(layer.size()):
		for y in range(layer[x].size()):
			var tile_data = layer[x][y]
			if tile_data != null and tile_data.has("atlas_coords") and tile_data.has("source_id"):
				tilemap.set_cell(Vector2i(x, y), tile_data.source_id, tile_data.atlas_coords)

func _apply_layer_to_node(layer_index: int, parent_node: Node) -> void:
	var layer = layer_data[layer_index]
	for x in range(layer.size()):
		for y in range(layer[x].size()):
			var entity_data = layer[x][y]
			if entity_data != null and entity_data.has("scene") and entity_data.has("position"):
				var instance = entity_data.scene.instantiate()
				instance.position = entity_data.position
				
				# Set sprite type if specified
				if entity_data.has("sprite_type"):
					instance.set_sprite_type(entity_data.sprite_type)
				
				parent_node.add_child(instance)

func get_layer_data_at(layer_index: int, x: int, y: int):
	if layer_index < 0 or layer_index >= layer_data.size():
		return null
	if x < 0 or x >= layer_data[layer_index].size():
		return null
	if y < 0 or y >= layer_data[layer_index][x].size():
		return null
	return layer_data[layer_index][x][y]

func set_layer_data_at(layer_index: int, x: int, y: int, data) -> void:
	if layer_index >= 0 and layer_index < layer_data.size():
		if x >= 0 and x < layer_data[layer_index].size():
			if y >= 0 and y < layer_data[layer_index][x].size():
				layer_data[layer_index][x][y] = data
