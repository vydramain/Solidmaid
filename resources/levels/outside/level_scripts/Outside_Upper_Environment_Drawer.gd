extends Node
class_name Outside_Upper_Environment_Drawer

# Reference to the 3D layer data array from ChunkManager
var layer_data: Array[Array] = []

# Scene references for final application (used by ChunkManager)
var environment_layer_1: Node
var environment_layer_2: Node

# Preloaded scenes
var FenceScene := preload("res://resources/entity/environment/fence/Fence.tscn")

func draw_upper_environment_layer_1_to_layer_data(current_chunk_type: Outside_Constants.UPPER_CHUNK, current_chunk_index: int, layer_index: int, background_context: Array, decorations_context: Array) -> void:
	Logger.log(self, "[ENVIRONMENT_L1] Start drawing upper environment layer 1 | Type: " + str(current_chunk_type) + ", Index: " + str(current_chunk_index) + " | layer=" + str(layer_index))
	
	var start_y = 0  # Upper chunk always starts at row 0
	var start_x = current_chunk_index * Outside_Constants.CHUNK_TILE_WIDTH  # Horizontal offset by index
	
	match current_chunk_type:
		Outside_Constants.UPPER_CHUNK.CROSS_START, Outside_Constants.UPPER_CHUNK.CROSS_END:
			_fill_cross_environment_layer_1(start_x, start_y, layer_index, background_context, decorations_context)
		Outside_Constants.UPPER_CHUNK.LIGTH_BUILDING, Outside_Constants.UPPER_CHUNK.BLUE_BUILDING, Outside_Constants.UPPER_CHUNK.PARK, Outside_Constants.UPPER_CHUNK.FACTORY:
			# No grass placement for road chunks
			Logger.log(self, "[ENVIRONMENT_L1] Skipping placement for buildings/park/factory chunk type: " + str(current_chunk_type))
		_:
			Logger.log(self, "[ENVIRONMENT_L1] Unsupported chunk type for environment layer 1: " + str(current_chunk_type))

func draw_upper_environment_layer_2_to_layer_data(current_chunk_type: Outside_Constants.UPPER_CHUNK, current_chunk_index: int, layer_index: int, background_context: Array, decorations_context: Array, env1_context: Array) -> void:
	Logger.log(self, "[ENVIRONMENT_L2] Start drawing lower environment layer 2 | Type: " + str(current_chunk_type) + ", Index: " + str(current_chunk_index) + " | layer=" + str(layer_index))
	
	var start_y = 0  # Upper chunk always starts at row 0
	var start_x = current_chunk_index * Outside_Constants.CHUNK_TILE_WIDTH  # Horizontal offset by index
	
	match current_chunk_type:
		Outside_Constants.UPPER_CHUNK.LIGTH_BUILDING, Outside_Constants.UPPER_CHUNK.BLUE_BUILDING, Outside_Constants.UPPER_CHUNK.PARK, Outside_Constants.UPPER_CHUNK.FACTORY, Outside_Constants.UPPER_CHUNK.CROSS_START, Outside_Constants.UPPER_CHUNK.CROSS_END:
			# No tree placement for road chunks
			Logger.log(self, "[ENVIRONMENT_L2] Skipping placement for buildings/park/factory/cross chunk type: " + str(current_chunk_type))
		_:
			Logger.log(self, "[ENVIRONMENT_L2] Unsupported chunk type for environment layer 2: " + str(current_chunk_type))

func _fill_cross_environment_layer_1(start_x: int, start_y: int, layer_index: int, background_context: Array, decorations_context: Array) -> void:
	Logger.log(self, "[CROSS_ENV_L1] Placing cross entities | Start position: (" + str(start_x) + ", " + str(start_y) + ")")
	
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT):
		for col in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			pass
