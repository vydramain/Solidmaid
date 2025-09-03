extends Node
class_name Outside_Lower_Decorations_Drawer

var decorations_scene: TileMapLayer

func draw_lower_decorations(decorations_scene: TileMapLayer, current_chunk_type: Outside_Constants.LOWER_CHUNK, current_chunk_index: int) -> void:
	Logger.log(self, "[DRAW_CHUNK] Start drawing lower decorations | Type: " + str(current_chunk_type) + ", Index: " + str(current_chunk_index))
	
	var start_y = 0  # Lower chunk always starts at row 0
	var start_x = current_chunk_index * Outside_Constants.CHUNK_TILE_WIDTH  # Horizontal offset by index
	
	match current_chunk_type:
		Outside_Constants.LOWER_CHUNK.GRASS:
			_fill_grass_area(decorations_scene, start_x, start_y)
		Outside_Constants.LOWER_CHUNK.ROAD:
			_fill_road_area(decorations_scene, start_x, start_y)
		Outside_Constants.LOWER_CHUNK.PARK:
			Logger.log(self, "[DRAW_CHUNK] PARK chunk type currently not implemented")
		Outside_Constants.LOWER_CHUNK.CROSS_START:
			_fill_cross_area(decorations_scene, start_x, start_y)
		_:
			Logger.log(self, "[DRAW_CHUNK] Unsupported lower chunk type: " + str(current_chunk_type))


func _fill_grass_area(decorations_scene: TileMapLayer, start_x: int, start_y: int) -> void:
	Logger.log(self, "[GRASS] Placing grass sidewalk tiles | Start position: (" + str(start_x) + ", " + str(start_y) + ")")
	
	 # Drawing
	var tile_count = 0
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT - 5):
		for col in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			if (col == 5 or col == 6):
				var cell_pos = Vector2i(start_x + col, start_y + row)
				var atlas_coords = Outside_Constants.CONCRETE_BACKGROUND_TILES_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[0]
				var atlas_coords_modificator_x = randi() % Outside_Constants.CONCRETE_BACKGROUND_TILE_SIZE.x
				var atlas_coords_modificator_y = randi() % Outside_Constants.CONCRETE_BACKGROUND_TILE_SIZE.y
				decorations_scene.set_cell(cell_pos, Outside_Constants.ATLAS_SOURCE_ID, atlas_coords + Vector2i(atlas_coords_modificator_x, atlas_coords_modificator_y))
			tile_count += 1
	
	# Drwaing line of sidewalk
	tile_count = 0
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT + 2, Outside_Constants.CHUNK_TILE_HEIGHT - 3):
		for col in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			var cell_pos = Vector2i(start_x + col, start_y + row)
			var atlas_coords = Outside_Constants.CONCRETE_BACKGROUND_TILES_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[0]
			var atlas_coords_modificator_x = randi() % Outside_Constants.CONCRETE_BACKGROUND_TILE_SIZE.x
			var atlas_coords_modificator_y = randi() % Outside_Constants.CONCRETE_BACKGROUND_TILE_SIZE.y
			decorations_scene.set_cell(cell_pos, Outside_Constants.ATLAS_SOURCE_ID, atlas_coords + Vector2i(atlas_coords_modificator_x, atlas_coords_modificator_y))
			tile_count += 1
			
	Logger.log(self, "[GRASS] Grass tiles placed | Total tiles: " + str(tile_count))
	Logger.log(self, "[GRASS] Completed grass area")

func _fill_road_area(decorations_scene: TileMapLayer, start_x: int, start_y: int) -> void:
	pass

func _fill_cross_area(decorations_scene: TileMapLayer, start_x: int, start_y: int) -> void:
	pass
