extends Node2D
class_name Outside_Lower_Chunk_Drawer


var background_scene: TileMapLayer

func draw_lower_chunk(background_scene: TileMapLayer, current_chunk_type: Outside_Constants.LOWER_CHUNK, current_chunk_index: int) -> void:
	Logger.log(self, "start | type=" + str(current_chunk_type) + " index=" + str(current_chunk_index))
	var start_y = 0                                                # upper chunk always starts at row 0
	var start_x = current_chunk_index * Outside_Constants.CHUNK_TILE_WIDTH  # offset horizontally by index
	
	match current_chunk_type:
		Outside_Constants.LOWER_CHUNK.GRASS:
			_fill_grass_area(background_scene, start_x, start_y)
		Outside_Constants.LOWER_CHUNK.ROAD:
			_fill_road_area(background_scene, start_x, start_y)
		Outside_Constants.LOWER_CHUNK.PARK:
			pass
		Outside_Constants.LOWER_CHUNK.CROSS_START:
			_fill_cross_area(background_scene, start_x, start_y)
		_:
			Logger.log(self, "Lower chunk type not implemented: " + str(current_chunk_type))


func _fill_grass_area(background_scene: TileMapLayer, start_x: int, start_y: int) -> void:
	Logger.log(self, "_fill_grass_area - start | start_x=" + str(start_x) + " start_y=" + str(start_y))
	
	# lower grass part
	for ii in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT):
		for i in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			var y_pos = start_y + ii
			var x_pos = start_x + i
			
			var cell_pos = Vector2i(x_pos, y_pos)
			var atlas_coords_index = randi() % Outside_Constants.GRASS_BACKGROUND_TILES_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()
			var atlas_coords_of_tile = Outside_Constants.GRASS_BACKGROUND_TILES_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[atlas_coords_index]
			background_scene.set_cell(cell_pos, Outside_Constants.ATLAS_SOURCE_ID, atlas_coords_of_tile)
			
	Logger.log(self, "upper sidewalk tiles placed: count=" + str(Outside_Constants.CHUNK_TILE_WIDTH))
	
	Logger.log(self, "completed")


func _fill_road_area(background_scene: TileMapLayer, start_x: int, start_y: int) -> void:
	Logger.log(self, "start | start_x=" + str(start_x) + " start_y=" + str(start_y))
	
	# lower sidewalk part
	for ii in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT - 2):
		for i in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			var y_pos = start_y + ii
			var x_pos = start_x + i
			
			var cell_pos = Vector2i(x_pos, y_pos)
			var atlas_coords_index = randi() % Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()
			var atlas_coords_of_tile = Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[atlas_coords_index]
			background_scene.set_cell(cell_pos, Outside_Constants.ATLAS_SOURCE_ID, atlas_coords_of_tile)
	
	Logger.log(self, "lower sidewalk tiles placed: count=" + str(Outside_Constants.CHUNK_TILE_WIDTH))
	
	# lower road part
	for ii in range(Outside_Constants.CHUNK_TILE_HEIGHT - 2, Outside_Constants.CHUNK_TILE_HEIGHT):
		for i in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			var y_pos = start_y + ii
			var x_pos = start_x + i
			
			var cell_pos = Vector2i(x_pos, y_pos)
			var atlas_coords_index = randi() % Outside_Constants.ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()
			var atlas_coords_of_tile = Outside_Constants.ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[atlas_coords_index]
			background_scene.set_cell(cell_pos, Outside_Constants.ATLAS_SOURCE_ID, atlas_coords_of_tile)
			
	Logger.log(self, "lower sidewalk tiles placed: count=" + str(Outside_Constants.CHUNK_TILE_WIDTH))
	
	Logger.log(self, "completed")


func _fill_cross_area(background_scene: TileMapLayer, start_x: int, start_y: int) -> void:
	Logger.log(self, "start | start_x=" + str(start_x) + " start_y=" + str(start_y))
	
	# Lower sidewalk part
	for ii in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT):
		var sidewalk_indent = 0
		for i in range(0, 4):
			var y_pos = start_y + ii
			var x_pos = start_x + sidewalk_indent
			
			var indent_flag = i % 4
			if indent_flag == 1 or indent_flag == 3:
				sidewalk_indent += 7
			else:
				sidewalk_indent += 1
			
			var cell_pos = Vector2i(x_pos, y_pos)
			var atlas_coords_index = randi() % Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()
			var atlas_coords_of_tile = Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[atlas_coords_index]
			if !((indent_flag == 2 or indent_flag == 3) and (Outside_Constants.CHUNK_TILE_HEIGHT - 2 <= ii)):
				background_scene.set_cell(cell_pos, Outside_Constants.ATLAS_SOURCE_ID, atlas_coords_of_tile)
	
	# Upper road part
	for ii in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT):
		var road_indent = 0
		for i in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			var y_pos = start_y + ii
			var x_pos = start_x + road_indent
			
			road_indent += 1
			
			var cell_pos = Vector2i(x_pos, y_pos)
			var atlas_coords_index = randi() % Outside_Constants.ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()
			var atlas_coords_of_tile = Outside_Constants.ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[atlas_coords_index]
			if ((1 < i and i < Outside_Constants.CHUNK_TILE_WIDTH - 2) or (Outside_Constants.CHUNK_TILE_WIDTH - 3 < i and Outside_Constants.CHUNK_TILE_HEIGHT - 3 < ii)):
				background_scene.set_cell(cell_pos, Outside_Constants.ATLAS_SOURCE_ID, atlas_coords_of_tile)
	
	Logger.log(self, "upper sidewalk tiles placed: count=" + str(Outside_Constants.CHUNK_TILE_WIDTH))
	
	Logger.log(self, "completed")
