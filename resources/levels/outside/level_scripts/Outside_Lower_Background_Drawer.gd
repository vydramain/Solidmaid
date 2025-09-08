extends Node
class_name Outside_Lower_Background_Drawer

# Reference to the 3D layer data array from ChunkManager
var layer_data: Array[Array] = []

# Scene references for final application (used by ChunkManager)
var background_scene: TileMapLayer

func draw_lower_chunk_to_layer_data(current_chunk_type: Outside_Constants.LOWER_CHUNK, current_chunk_index: int, layer_index: int) -> void:
	Logger.log(self, "[DRAW_CHUNK] Start drawing lower chunk | Type: " + str(current_chunk_type) + ", Index: " + str(current_chunk_index) + " | layer=" + str(layer_index))
	
	var start_y = 0  # Lower chunk always starts at row 0
	var start_x = current_chunk_index * Outside_Constants.CHUNK_TILE_WIDTH  # Horizontal offset by index
	
	match current_chunk_type:
		Outside_Constants.LOWER_CHUNK.GRASS:
			_fill_grass_area_to_layer_data(start_x, start_y, layer_index)
		Outside_Constants.LOWER_CHUNK.ROAD:
			_fill_road_area_to_layer_data(start_x, start_y, layer_index)
		Outside_Constants.LOWER_CHUNK.PARK:
			Logger.log(self, "[DRAW_CHUNK] PARK chunk type currently not implemented")
		Outside_Constants.LOWER_CHUNK.CROSS_START:
			_fill_cross_start_area_to_layer_data(start_x, start_y, layer_index)
		Outside_Constants.LOWER_CHUNK.CROSS_END:
			_fill_cross_end_area_to_layer_data(start_x, start_y, layer_index)
		_:
			Logger.log(self, "[DRAW_CHUNK] Unsupported lower chunk type: " + str(current_chunk_type))

func _set_tile_in_layer_data(x: int, y: int, layer_index: int, atlas_coords: Vector2i) -> void:
	"""Helper function to safely set tile data in the layer array"""
	if layer_index >= 0 and layer_index < layer_data.size():
		if x >= 0 and x < layer_data[layer_index].size():
			if y >= 0 and y < layer_data[layer_index][x].size():
				layer_data[layer_index][x][y] = {
					"source_id": Outside_Constants.ATLAS_SOURCE_ID,
					"atlas_coords": atlas_coords
				}

func _fill_grass_area_to_layer_data(start_x: int, start_y: int, layer_index: int) -> void:
	Logger.log(self, "[GRASS] Placing grass tiles | Start position: (" + str(start_x) + ", " + str(start_y) + ")")
	
	var tile_count = 0
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT):
		for col in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			var x_pos = start_x + col
			var y_pos = start_y + row
			var atlas_coords = Outside_Constants.GRASS_BACKGROUND_TILES_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[randi() % Outside_Constants.GRASS_BACKGROUND_TILES_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()]
			_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)
			tile_count += 1
			
	Logger.log(self, "[GRASS] Grass tiles placed | Total tiles: " + str(tile_count))
	Logger.log(self, "[GRASS] Completed grass area")

func _fill_road_area_to_layer_data(start_x: int, start_y: int, layer_index: int) -> void:
	Logger.log(self, "[ROAD] Start placing road and sidewalk tiles | Start position: (" + str(start_x) + ", " + str(start_y) + ")")
	
	var sidewalk_count = 0
	# Sidewalk
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT - 2):
		for col in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			var x_pos = start_x + col
			var y_pos = start_y + row
			var atlas_coords = Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[randi() % Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()]
			_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)
			sidewalk_count += 1
	
	Logger.log(self, "[ROAD] Sidewalk tiles placed | Total tiles: " + str(sidewalk_count))
	
	var road_count = 0
	# Road
	for row in range(Outside_Constants.CHUNK_TILE_HEIGHT - 2, Outside_Constants.CHUNK_TILE_HEIGHT):
		for col in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			var x_pos = start_x + col
			var y_pos = start_y + row
			var atlas_coords = Outside_Constants.ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[randi() % Outside_Constants.ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()]
			_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)
			road_count += 1
			
	Logger.log(self, "[ROAD] Road tiles placed | Total tiles: " + str(road_count))
	Logger.log(self, "[ROAD] Completed road area")

func _fill_cross_start_area_to_layer_data(start_x: int, start_y: int, layer_index: int) -> void:
	Logger.log(self, "[CROSS_START] Start placing cross start area tiles | Start position: (" + str(start_x) + ", " + str(start_y) + ")")
	
	var sidewalk_count = 0
	# Sidewalk pattern
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT):
		var sidewalk_indent = 0
		for i in range(0, 4):
			var indent_flag = i % 4
			var x_pos = start_x + sidewalk_indent
			var y_pos = start_y + row
			sidewalk_indent += (7 if indent_flag in [1,3] else 1)
			
			if !((indent_flag in [2,3]) and (row >= Outside_Constants.CHUNK_TILE_HEIGHT - 2)):
				var atlas_coords = Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[randi() % Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()]
				_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)
				sidewalk_count += 1
				
	Logger.log(self, "[CROSS_START] Sidewalk tiles placed | Total tiles: " + str(sidewalk_count))
	
	var road_count = 0
	# Road pattern
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT):
		var road_indent = 0
		for col in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			var x_pos = start_x + road_indent
			var y_pos = start_y + row
			road_indent += 1
			
			if ((1 < col) and (col < Outside_Constants.CHUNK_TILE_WIDTH - 2)) or ((col > Outside_Constants.CHUNK_TILE_WIDTH - 3) and (row > Outside_Constants.CHUNK_TILE_HEIGHT - 3)):
				var atlas_coords = Outside_Constants.ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[randi() % Outside_Constants.ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()]
				_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)
				road_count += 1
	
	Logger.log(self, "[CROSS_START] Cross start tiles placed | Total tiles: " + str(road_count))
	Logger.log(self, "[CROSS_START] Completed cross start area")

func _fill_cross_end_area_to_layer_data(start_x: int, start_y: int, layer_index: int) -> void:
	Logger.log(self, "[CROSS_END] Start placing cross end area tiles | Start position: (" + str(start_x) + ", " + str(start_y) + ")")
	
	var sidewalk_count = 0
	# Sidewalk pattern
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT):
		var sidewalk_indent = 0
		for col in range(0, 4):
			var indent_flag = col % 4
			var x_pos = start_x + sidewalk_indent
			var y_pos = start_y + row
			sidewalk_indent += (7 if indent_flag in [1,3] else 1)
			
			if !((indent_flag in [0,1]) and (row >= Outside_Constants.CHUNK_TILE_HEIGHT - 2)):
				var atlas_coords = Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[randi() % Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()]
				_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)
				sidewalk_count += 1
				
	Logger.log(self, "[CROSS_ENDS] Sidewalk tiles placed | Total tiles: " + str(sidewalk_count))
	
	var road_count = 0
	# Road pattern
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT):
		var road_indent = 0
		for col in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			var x_pos = start_x + road_indent
			var y_pos = start_y + row
			road_indent += 1
			
			if ((1 < col) and (col < Outside_Constants.CHUNK_TILE_WIDTH - 2)) or ((col < Outside_Constants.CHUNK_TILE_WIDTH - 3) and (row > Outside_Constants.CHUNK_TILE_HEIGHT - 3)):
				var atlas_coords = Outside_Constants.ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[randi() % Outside_Constants.ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()]
				_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)
				road_count += 1
	
	Logger.log(self, "[CROSS_END] Cross end tiles placed | Total tiles: " + str(road_count))
	Logger.log(self, "[CROSS_END] Completed cross area")
