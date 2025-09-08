extends Node
class_name Outside_Lower_Decorations_Drawer

# Reference to the 3D layer data array from ChunkManager
var layer_data: Array[Array] = []

# Scene references for final application (used by ChunkManager)
var decorations_scene: TileMapLayer

func draw_lower_decorations_to_layer_data(current_chunk_type: Outside_Constants.LOWER_CHUNK, current_chunk_index: int, layer_index: int, background_context: Array) -> void:
	Logger.log(self, "[DRAW_CHUNK_DECORATIONS] Start drawing lower chunk decorations | Type: " + str(current_chunk_type) + ", Index: " + str(current_chunk_index) + " | layer=" + str(layer_index))
	
	var start_y = 0  # Lower chunk always starts at row 0
	var start_x = current_chunk_index * Outside_Constants.CHUNK_TILE_WIDTH  # Horizontal offset by index
	
	match current_chunk_type:
		Outside_Constants.LOWER_CHUNK.GRASS:
			_fill_grass_area_to_layer_data(start_x, start_y, layer_index, background_context)
		Outside_Constants.LOWER_CHUNK.ROAD:
			_fill_road_area_to_layer_data(start_x, start_y, layer_index, background_context)
		Outside_Constants.LOWER_CHUNK.PARK:
			Logger.log(self, "[DRAW_CHUNK_DECORATIONS] PARK chunk type currently not implemented")
		Outside_Constants.LOWER_CHUNK.CROSS_START:
			_fill_cross_start_area_to_layer_data(start_x, start_y, layer_index, background_context)
		Outside_Constants.LOWER_CHUNK.CROSS_END:
			_fill_cross_end_area_to_layer_data(start_x, start_y, layer_index, background_context)
		_:
			Logger.log(self, "[DRAW_CHUNK_DECORATIONS] Unsupported lower chunk decorations type: " + str(current_chunk_type))

func _set_tile_in_layer_data(x: int, y: int, layer_index: int, atlas_coords: Vector2i) -> void:
	"""Helper function to safely set tile data in the layer array"""
	if layer_index >= 0 and layer_index < layer_data.size():
		if x >= 0 and x < layer_data[layer_index].size():
			if y >= 0 and y < layer_data[layer_index][x].size():
				layer_data[layer_index][x][y] = {
					"source_id": Outside_Constants.ATLAS_SOURCE_ID,
					"atlas_coords": atlas_coords
				}

func _fill_grass_area_to_layer_data(start_x: int, start_y: int, layer_index: int, background_context: Array) -> void:
	Logger.log(self, "[GRASS] Placing grass sidewalk tiles | Start position: (" + str(start_x) + ", " + str(start_y) + ")")
	
	# Drawing entrances
	var tile_count = 0
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT - 4):
		for col in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			if (col == 4 or col == 5):
				var x_pos = start_x + col
				var y_pos = start_y + row
				var atlas_coords = Outside_Constants.GRASS_SIDEWALK_DECORATION_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[0]
				var atlas_coords_modificator_x = randi() % Outside_Constants.GRASS_SIDEWALK_DECORATION_TILE_SIZE.x
				var atlas_coords_modificator_y = randi() % Outside_Constants.GRASS_SIDEWALK_DECORATION_TILE_SIZE.y
				_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords + Vector2i(atlas_coords_modificator_x, atlas_coords_modificator_y))
			tile_count += 1
	
	# Drawing line of sidewalk
	tile_count = 0
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT + 2, Outside_Constants.CHUNK_TILE_HEIGHT - 2):
		for col in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			var x_pos = start_x + col
			var y_pos = start_y + row
			var atlas_coords = Outside_Constants.GRASS_SIDEWALK_DECORATION_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[0]
			var atlas_coords_modificator_x = randi() % Outside_Constants.GRASS_SIDEWALK_DECORATION_TILE_SIZE.x
			var atlas_coords_modificator_y = randi() % Outside_Constants.GRASS_SIDEWALK_DECORATION_TILE_SIZE.y
			_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords + Vector2i(atlas_coords_modificator_x, atlas_coords_modificator_y))
			tile_count += 1
			
	Logger.log(self, "[GRASS] Grass tiles placed | Total tiles: " + str(tile_count))
	Logger.log(self, "[GRASS] Completed grass area")

func _fill_road_area_to_layer_data(start_x: int, start_y: int, layer_index: int, background_context: Array) -> void:
	Logger.log(self, "[ROAD] Placing road tiles | Start position: (" + str(start_x) + ", " + str(start_y) + ")")
	
	# Drawing concrete
	var tile_count = 0
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT + 4, Outside_Constants.CHUNK_TILE_HEIGHT - 1):
		for col in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			var x_pos = start_x + col
			var y_pos = start_y + row
			var atlas_coords = Outside_Constants.CONCRETE_END_UP_BACKGROUND_TILES_ATLAS_COORDS[
				randi() % Outside_Constants.CONCRETE_END_UP_BACKGROUND_TILES_ATLAS_COORDS.size()
			]
			_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)
			tile_count += 1
	
	Logger.log(self, "[ROAD] Road tiles placed | Total tiles: " + str(tile_count))
	Logger.log(self, "[ROAD] Completed road area")

func _fill_cross_start_area_to_layer_data(start_x: int, start_y: int, layer_index: int, background_context: Array) -> void:
	Logger.log(self, "[CROSS_START] Placing cross tiles | Start position: (" + str(start_x) + ", " + str(start_y) + ")")
	
	# Drawing concrete - left side
	var tile_count = 0
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT):
		var x_pos = start_x
		var y_pos = start_y + row
		var atlas_coords = Outside_Constants.CONCRETE_END_LEFT_BACKGROUND_TILES_ATLAS_COORDS[
			randi() % Outside_Constants.CONCRETE_END_LEFT_BACKGROUND_TILES_ATLAS_COORDS.size()
		]
		_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)
		tile_count += 1
		
		x_pos = start_x + 1
		atlas_coords = Outside_Constants.CONCRETE_END_RIGHT_BACKGROUND_TILES_ATLAS_COORDS[
			randi() % Outside_Constants.CONCRETE_END_RIGHT_BACKGROUND_TILES_ATLAS_COORDS.size()
		]
		_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)
		tile_count += 1
	
	# Drawing concrete - right side vertical
	tile_count = 0
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT - 2):
		var x_pos = start_x + 8
		var y_pos = start_y + row
		var atlas_coords = Outside_Constants.CONCRETE_END_LEFT_BACKGROUND_TILES_ATLAS_COORDS[
			randi() % Outside_Constants.CONCRETE_END_LEFT_BACKGROUND_TILES_ATLAS_COORDS.size()
		]
		_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)
		tile_count += 1
	
	# Drawing concrete - right side horizontal
	tile_count = 0
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT + 4, Outside_Constants.CHUNK_TILE_HEIGHT - 1):
		for col in range(8, Outside_Constants.CHUNK_TILE_WIDTH):
			var x_pos = start_x + col
			var y_pos = start_y + row
			var atlas_coords = Outside_Constants.CONCRETE_END_UP_BACKGROUND_TILES_ATLAS_COORDS[
				randi() % Outside_Constants.CONCRETE_END_UP_BACKGROUND_TILES_ATLAS_COORDS.size()
			]
			_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)
			tile_count += 1
	
	# Drawing crosswalk
	tile_count = 0
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT + 1, Outside_Constants.CHUNK_TILE_HEIGHT - 3):
		for col in range(2, Outside_Constants.CHUNK_TILE_WIDTH - 2):
			var x_pos = start_x + col
			var y_pos = start_y + row
			var atlas_coords = Outside_Constants.CROSSWALK_BACKGROUND_TILES_ATLAS_COORDS[
				randi() % Outside_Constants.CROSSWALK_BACKGROUND_TILES_ATLAS_COORDS.size()
			]
			_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)
			tile_count += 1
	
	Logger.log(self, "[CROSS_START] cross tiles placed | Total tiles: " + str(tile_count))
	Logger.log(self, "[CROSS_START] Completed cross area")

func _fill_cross_end_area_to_layer_data(start_x: int, start_y: int, layer_index: int, background_context: Array) -> void:
	Logger.log(self, "[CROSS_END] Placing cross tiles | Start position: (" + str(start_x) + ", " + str(start_y) + ")")
	
	# Drawing concrete - right side
	var tile_count = 0
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT):
		var x_pos = start_x + 8
		var y_pos = start_y + row
		var atlas_coords = Outside_Constants.CONCRETE_END_LEFT_BACKGROUND_TILES_ATLAS_COORDS[
			randi() % Outside_Constants.CONCRETE_END_LEFT_BACKGROUND_TILES_ATLAS_COORDS.size()
		]
		_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)
		tile_count += 1
		
		x_pos = start_x + 9
		atlas_coords = Outside_Constants.CONCRETE_END_RIGHT_BACKGROUND_TILES_ATLAS_COORDS[
			randi() % Outside_Constants.CONCRETE_END_RIGHT_BACKGROUND_TILES_ATLAS_COORDS.size()
		]
		_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)
		tile_count += 1
	
	# Drawing concrete - left side vertical
	tile_count = 0
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT - 2):
		var x_pos = start_x + 1
		var y_pos = start_y + row
		var atlas_coords = Outside_Constants.CONCRETE_END_RIGHT_BACKGROUND_TILES_ATLAS_COORDS[
			randi() % Outside_Constants.CONCRETE_END_RIGHT_BACKGROUND_TILES_ATLAS_COORDS.size()
		]
		_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)
		tile_count += 1
	
	# Drawing concrete - left side horizontal
	tile_count = 0
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT + 4, Outside_Constants.CHUNK_TILE_HEIGHT - 1):
		for col in range(0, Outside_Constants.CHUNK_TILE_WIDTH - 8):
			var x_pos = start_x + col
			var y_pos = start_y + row
			var atlas_coords = Outside_Constants.CONCRETE_END_UP_BACKGROUND_TILES_ATLAS_COORDS[
				randi() % Outside_Constants.CONCRETE_END_UP_BACKGROUND_TILES_ATLAS_COORDS.size()
			]
			_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)
			tile_count += 1
	
	# Drawing crosswalk
	tile_count = 0
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT + 1, Outside_Constants.CHUNK_TILE_HEIGHT - 3):
		for col in range(2, Outside_Constants.CHUNK_TILE_WIDTH - 2):
			var x_pos = start_x + col
			var y_pos = start_y + row
			var atlas_coords = Outside_Constants.CROSSWALK_BACKGROUND_TILES_ATLAS_COORDS[
				randi() % Outside_Constants.CROSSWALK_BACKGROUND_TILES_ATLAS_COORDS.size()
			]
			_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)
			tile_count += 1
	
	Logger.log(self, "[CROSS_END] cross tiles placed | Total tiles: " + str(tile_count))
	Logger.log(self, "[CROSS_END] Completed cross area")
