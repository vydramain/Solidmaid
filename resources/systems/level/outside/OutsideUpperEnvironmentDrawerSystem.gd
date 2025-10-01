extends Node
class_name Outside_Upper_Environment_Drawer

# Reference to the 3D layer data array from ChunkManager
var layer_data: Array[Array] = []

# Scene references for final application (used by ChunkManager)
var environment_layer_1: Node
var environment_layer_2: Node

# Preloaded scenes
var FenceScene := preload(Resource_Registry.ENVIRONMENT["FENCE"])

func draw_upper_environment_layer_1_to_layer_data(current_chunk_type: Outside_Constants.UPPER_CHUNK, current_chunk_index: int, layer_index: int, background_context: Array, decorations_context: Array) -> void:
	Custom_Logger.log(self, "[ENVIRONMENT_L1] Start drawing upper environment layer 1 | Type: " + str(current_chunk_type) + ", Index: " + str(current_chunk_index) + " | layer=" + str(layer_index))
	
	var start_y = 0  # Upper chunk always starts at row 0
	var start_x = current_chunk_index * Outside_Constants.CHUNK_TILE_WIDTH  # Horizontal offset by index
	
	match current_chunk_type:
		Outside_Constants.UPPER_CHUNK.CROSS_START, Outside_Constants.UPPER_CHUNK.CROSS_END, Outside_Constants.UPPER_CHUNK.LIGTH_BUILDING, Outside_Constants.UPPER_CHUNK.BLUE_BUILDING, Outside_Constants.UPPER_CHUNK.PARK, Outside_Constants.UPPER_CHUNK.FACTORY:
			# No grass placement for road chunks
			Custom_Logger.log(self, "[ENVIRONMENT_L1] Skipping placement for buildings/park/factory chunk type: " + str(current_chunk_type))
		_:
			Custom_Logger.log(self, "[ENVIRONMENT_L1] Unsupported chunk type for environment layer 1: " + str(current_chunk_type))

func draw_upper_environment_layer_2_to_layer_data(current_chunk_type: Outside_Constants.UPPER_CHUNK, current_chunk_index: int, layer_index: int, background_context: Array, decorations_context: Array, env1_context: Array) -> void:
	Custom_Logger.log(self, "[ENVIRONMENT_L2] Start drawing lower environment layer 2 | Type: " + str(current_chunk_type) + ", Index: " + str(current_chunk_index) + " | layer=" + str(layer_index))
	
	var start_y = 0  # Upper chunk always starts at row 0
	var start_x = current_chunk_index * Outside_Constants.CHUNK_TILE_WIDTH  # Horizontal offset by index
	
	match current_chunk_type:
		Outside_Constants.UPPER_CHUNK.CROSS_START, Outside_Constants.UPPER_CHUNK.CROSS_END:
			_fill_cross_environment_layer_2(start_x, start_y, layer_index, background_context, decorations_context)
		Outside_Constants.UPPER_CHUNK.LIGTH_BUILDING, Outside_Constants.UPPER_CHUNK.BLUE_BUILDING, Outside_Constants.UPPER_CHUNK.PARK, Outside_Constants.UPPER_CHUNK.FACTORY:
			# No tree placement for road chunks
			Custom_Logger.log(self, "[ENVIRONMENT_L2] Skipping placement for buildings/park/factory/cross chunk type: " + str(current_chunk_type))
		_:
			Custom_Logger.log(self, "[ENVIRONMENT_L2] Unsupported chunk type for environment layer 2: " + str(current_chunk_type))

func _is_tile_covered_by_decoration(x: int, y: int, decorations_context: Array) -> bool:
	"""Check if a tile position is covered by decoration tiles"""
	if x >= 0 and x < decorations_context.size():
		if y >= 0 and y < decorations_context[x].size():
			return decorations_context[x][y] != null
	return false

func _can_place_entity_at(tile_x: int, tile_y: int, tile_width: int, tile_height: int, decorations_context: Array, env1_context: Array = []) -> bool:
	"""Check if entity can be placed at given position (no decorations or existing environment objects)"""
	
	# Check all tiles that the entity would occupy
	for y_offset in range(tile_height):
		for x_offset in range(tile_width):
			var check_x = tile_x + x_offset
			var check_y = tile_y + y_offset
			
			# Check for decorations
			if _is_tile_covered_by_decoration(check_x, check_y, decorations_context):
				return false
			
			# Check for existing environment layer 1 objects (only when placing layer 2)
			if env1_context.size() > 0:
				if check_x >= 0 and check_x < env1_context.size():
					if check_y >= 0 and check_y < env1_context[check_x].size():
						if env1_context[check_x][check_y] != null:
							return false
	
	return true

func _set_entity_in_layer_data(x: int, y: int, layer_index: int, scene: PackedScene, world_position: Vector2) -> void:
	"""Helper function to safely set entity data in the layer array"""
	if layer_index >= 0 and layer_index < layer_data.size():
		if x >= 0 and x < layer_data[layer_index].size():
			if y >= 0 and y < layer_data[layer_index][x].size():
				layer_data[layer_index][x][y] = {
					"scene": scene,
					"position": world_position,
				}

func _fill_cross_environment_layer_2(start_x: int, start_y: int, layer_index: int, background_context: Array, decorations_context: Array) -> void:
	Custom_Logger.log(self, "[FENCE_ENV_L2] Placing fence entities | Start position: (" + str(start_x) + ", " + str(start_y) + ")")
	
	for row in range(3, Outside_Constants.UPPER_CHUNK_TILE_HEIGHT - 1):
		for col in range(0, Outside_Constants.CHUNK_TILE_WIDTH, 2):
			var tile_x = start_x + col
			var tile_y = start_y + row
			
			# Check if we can place grass here (no decorations)
			if _can_place_entity_at(tile_x, tile_y, 1, 1, decorations_context):
				var world_position = Vector2(tile_x * Outside_Constants.TILE_SIZE, tile_y * Outside_Constants.TILE_SIZE)
				_set_entity_in_layer_data(tile_x, tile_y, layer_index,  FenceScene, world_position)

	
	Custom_Logger.log(self, "[FENCE_ENV_L2] Fence placement complete")
