extends Node2D
class_name Outside_Lower_Chunk_Drawer

var background_scene: TileMapLayer

func draw_lower_chunk(current_chunk_type: Outside_Constants.LOWER_CHUNK, current_chunk_index: int) -> void:
	Logger.log(self, "[DRAW_CHUNK] Start drawing lower chunk | Type: " + str(current_chunk_type) + ", Index: " + str(current_chunk_index))
	
	var start_y = 0  # Lower chunk always starts at row 0
	var start_x = current_chunk_index * Outside_Constants.CHUNK_TILE_WIDTH  # Horizontal offset by index
	
	match current_chunk_type:
		Outside_Constants.LOWER_CHUNK.GRASS:
			_fill_grass_area(start_x, start_y)
		Outside_Constants.LOWER_CHUNK.ROAD:
			_fill_road_area(start_x, start_y)
		Outside_Constants.LOWER_CHUNK.PARK:
			Logger.log(self, "[DRAW_CHUNK] PARK chunk type currently not implemented")
		Outside_Constants.LOWER_CHUNK.CROSS_START:
			_fill_cross_start_area(start_x, start_y)
		Outside_Constants.LOWER_CHUNK.CROSS_END:
			_fill_cross_end_area(start_x, start_y)
		_:
			Logger.log(self, "[DRAW_CHUNK] Unsupported lower chunk type: " + str(current_chunk_type))


func _fill_grass_area(start_x: int, start_y: int) -> void:
	Logger.log(self, "[GRASS] Placing grass tiles | Start position: (" + str(start_x) + ", " + str(start_y) + ")")
	
	var tile_count = 0
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT):
		for col in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			var cell_pos = Vector2i(start_x + col, start_y + row)
			var atlas_coords = Outside_Constants.GRASS_BACKGROUND_TILES_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[randi() % Outside_Constants.GRASS_BACKGROUND_TILES_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()]
			background_scene.set_cell(cell_pos, Outside_Constants.ATLAS_SOURCE_ID, atlas_coords)
			tile_count += 1
			
	Logger.log(self, "[GRASS] Grass tiles placed | Total tiles: " + str(tile_count))
	Logger.log(self, "[GRASS] Completed grass area")


func _fill_road_area(start_x: int, start_y: int) -> void:
	Logger.log(self, "[ROAD] Start placing road and sidewalk tiles | Start position: (" + str(start_x) + ", " + str(start_y) + ")")
	
	var sidewalk_count = 0
	# Sidewalk
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT - 2):
		for col in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			var cell_pos = Vector2i(start_x + col, start_y + row)
			var atlas_coords = Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[randi() % Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()]
			background_scene.set_cell(cell_pos, Outside_Constants.ATLAS_SOURCE_ID, atlas_coords)
			sidewalk_count += 1
	
	Logger.log(self, "[ROAD] Sidewalk tiles placed | Total tiles: " + str(sidewalk_count))
	
	var road_count = 0
	# Road
	for row in range(Outside_Constants.CHUNK_TILE_HEIGHT - 2, Outside_Constants.CHUNK_TILE_HEIGHT):
		for col in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			var cell_pos = Vector2i(start_x + col, start_y + row)
			var atlas_coords = Outside_Constants.ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[randi() % Outside_Constants.ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()]
			background_scene.set_cell(cell_pos, Outside_Constants.ATLAS_SOURCE_ID, atlas_coords)
			road_count += 1
			
	Logger.log(self, "[ROAD] Road tiles placed | Total tiles: " + str(road_count))
	Logger.log(self, "[ROAD] Completed road area")


func _fill_cross_start_area(start_x: int, start_y: int) -> void:
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
			
			var cell_pos = Vector2i(x_pos, y_pos)
			if !((indent_flag in [2,3]) and (row >= Outside_Constants.CHUNK_TILE_HEIGHT - 2)):
				var atlas_coords = Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[randi() % Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()]
				background_scene.set_cell(cell_pos, Outside_Constants.ATLAS_SOURCE_ID, atlas_coords)
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
				var cell_pos = Vector2i(x_pos, y_pos)
				var atlas_coords = Outside_Constants.ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[randi() % Outside_Constants.ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()]
				background_scene.set_cell(cell_pos, Outside_Constants.ATLAS_SOURCE_ID, atlas_coords)
				road_count += 1
	
	Logger.log(self, "[CROSS_START] Cross start tiles placed | Total tiles: " + str(road_count))
	Logger.log(self, "[CROSS_START] Completed cross start area")


func _fill_cross_end_area(start_x: int, start_y: int) -> void:
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
			
			var cell_pos = Vector2i(x_pos, y_pos)
			if !((indent_flag in [0,1]) and (row >= Outside_Constants.CHUNK_TILE_HEIGHT - 2)):
				var atlas_coords = Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[randi() % Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()]
				background_scene.set_cell(cell_pos, Outside_Constants.ATLAS_SOURCE_ID, atlas_coords)
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
				var cell_pos = Vector2i(x_pos, y_pos)
				var atlas_coords = Outside_Constants.ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[randi() % Outside_Constants.ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()]
				background_scene.set_cell(cell_pos, Outside_Constants.ATLAS_SOURCE_ID, atlas_coords)
				road_count += 1
	
	Logger.log(self, "[CROSS_END] Cross end tiles placed | Total tiles: " + str(road_count))
	Logger.log(self, "[CROSS_END] Completed cross area")
