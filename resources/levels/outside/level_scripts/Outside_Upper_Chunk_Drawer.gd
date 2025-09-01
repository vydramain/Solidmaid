extends Node
class_name Outside_Upper_Chunk_Drawer


var background_scene: TileMapLayer

func draw_upper_chunk(background_scene: TileMapLayer, current_chunk_type: int, current_chunk_index: int) -> void:
	Logger.log(self, "start | type=" + str(current_chunk_type) + " index=" + str(current_chunk_index))
	var start_y = 0  # upper chunk always starts at row 0
	var start_x = current_chunk_index * Outside_Constants.CHUNK_TILE_WIDTH
	
	match current_chunk_type:
		Outside_Constants.UPPER_CHUNK.LIGTH_BUILDING:
			_fill_light_building(background_scene, start_x, start_y)
		Outside_Constants.UPPER_CHUNK.BLUE_BUILDING:
			_fill_blue_building(background_scene, start_x, start_y)
		Outside_Constants.UPPER_CHUNK.CROSS_START:
			_fill_cross_horizon(background_scene, start_x, start_y)
		Outside_Constants.UPPER_CHUNK.PARK:
			Logger.log(self, "PARK not implemented")
		Outside_Constants.UPPER_CHUNK.FACTORY:
			_fill_factory_building(background_scene, start_x, start_y)
		_:
			Logger.log(self, "Upper chunk type not implemented: " + str(current_chunk_type))
	
	Logger.log(self, "completed | type=" + str(current_chunk_type))


func _fill_light_building(background_scene: TileMapLayer, start_x: int, start_y: int) -> void:
	Logger.log(self, "start | start_x=" + str(start_x) + " start_y=" + str(start_y))
	
	# Basement
	for i in range(Outside_Constants.CHUNK_TILE_WIDTH / Outside_Constants.LIGHT_BUILDING_BASEMENT_TILE_SIZE.x):
		var x_pos = start_x + (i * Outside_Constants.LIGHT_BUILDING_BASEMENT_TILE_SIZE.x)
		var y_pos = start_y + 4
		var cell_pos = Vector2i(x_pos, y_pos)
		var atlas_coords = Outside_Constants.LIGHT_BUILDING_BASEMENT_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		for t in range(Outside_Constants.LIGHT_BUILDING_BASEMENT_TILE_SIZE.x):
			background_scene.set_cell(cell_pos + Vector2i(t, 0), Outside_Constants.ATLAS_SOURCE_ID, atlas_coords + Vector2i(t, 0))
	Logger.log(self, "basement placed")
	
	# First line of windows
	var first_indent = 0
	for i in range(Outside_Constants.CHUNK_TILE_WIDTH / (Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x + int(Outside_Constants.LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.x * 0.5))):
		var x_pos = start_x + first_indent
		var y_pos = start_y
		first_indent += (
			Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x + Outside_Constants.LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.x
			if i % 2 == 0
			else Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x
		)
		var cell_pos = Vector2i(x_pos, y_pos)
		var atlas_coords = Outside_Constants.LIGHT_BUILDING_WINDOWS_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		for t_y in range(Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.y):
			for t_x in range(Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x):
				background_scene.set_cell(cell_pos + Vector2i(t_x, t_y), Outside_Constants.ATLAS_SOURCE_ID, atlas_coords + Vector2i(t_x, t_y))
	Logger.log(self, "first windows placed")
	
	# Second line of windows
	var second_indent = 0
	for i in range(Outside_Constants.CHUNK_TILE_WIDTH / (Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x + int(Outside_Constants.LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.x * 0.5))):
		var x_pos = start_x + second_indent
		var y_pos = start_y + Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.y
		second_indent += (
			Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x + Outside_Constants.LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.x
			if i % 2 == 0
			else Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x
		)
		var cell_pos = Vector2i(x_pos, y_pos)
		var atlas_coords = Outside_Constants.LIGHT_BUILDING_WINDOWS_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		for t_y in range(Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.y):
			for t_x in range(Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x):
				background_scene.set_cell(cell_pos + Vector2i(t_x, t_y), Outside_Constants.ATLAS_SOURCE_ID, atlas_coords + Vector2i(t_x, t_y))
	Logger.log(self, "second windows placed")
	
	# Entrance windows
	for i in range(Outside_Constants.CHUNK_TILE_WIDTH / (Outside_Constants.LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.x + Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x * 2)):
		var x_pos = start_x + (i * (Outside_Constants.LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.x + Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x * 2)) + Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x
		var y_pos = start_y
		var cell_pos = Vector2i(x_pos, y_pos)
		var atlas_coords = Outside_Constants.LIGHT_BUILDING_ENTRANCE_WINDOW_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		for t_y in range(Outside_Constants.LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.y):
			for t_x in range(Outside_Constants.LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.x):
				background_scene.set_cell(cell_pos + Vector2i(t_x, t_y), Outside_Constants.ATLAS_SOURCE_ID, atlas_coords + Vector2i(t_x, t_y))
	Logger.log(self, "entrance windows placed")
	
	# Entrances
	for i in range(Outside_Constants.CHUNK_TILE_WIDTH / (Outside_Constants.LIGHT_BUILDING_ENTRANCE_TILE_SIZE.x + Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x * 2)):
		var x_pos = start_x + (i * (Outside_Constants.LIGHT_BUILDING_ENTRANCE_TILE_SIZE.x + Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x * 2)) + Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x
		var y_pos = start_y + Outside_Constants.LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.y
		var cell_pos = Vector2i(x_pos, y_pos)
		var atlas_coords = Outside_Constants.LIGHT_BUILDING_ENTRANCE_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		for t_y in range(Outside_Constants.LIGHT_BUILDING_ENTRANCE_TILE_SIZE.y):
			for t_x in range(Outside_Constants.LIGHT_BUILDING_ENTRANCE_TILE_SIZE.x):
				background_scene.set_cell(cell_pos + Vector2i(t_x, t_y), Outside_Constants.ATLAS_SOURCE_ID, atlas_coords + Vector2i(t_x, t_y))
	Logger.log(self, "entrances placed")
	Logger.log(self, "completed")


func _fill_blue_building(background_scene: TileMapLayer, start_x: int, start_y: int) -> void:
	Logger.log(self, "start | start_x=" + str(start_x) + " start_y=" + str(start_y))

	for i in range(Outside_Constants.CHUNK_TILE_WIDTH / Outside_Constants.BLUE_BUILDING_BASEMENT_TILE_SIZE.x):
		var x_pos = start_x + (i * Outside_Constants.BLUE_BUILDING_BASEMENT_TILE_SIZE.x)
		var y_pos = start_y + 4
		var cell_pos = Vector2i(x_pos, y_pos)
		var atlas_coords = Outside_Constants.BLUE_BUILDING_BASEMENT_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		for t in range(Outside_Constants.BLUE_BUILDING_BASEMENT_TILE_SIZE.x):
			background_scene.set_cell(cell_pos + Vector2i(t, 0), Outside_Constants.ATLAS_SOURCE_ID, atlas_coords + Vector2i(t, 0))
	Logger.log(self, "basement placed")

	# Windows line 1
	var indent = 0
	for i in range(Outside_Constants.CHUNK_TILE_WIDTH / Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.x):
		var cell_pos = Vector2i(start_x + indent, start_y)
		indent += Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.x
		var atlas_coords = Outside_Constants.BLUE_BUILDING_WINDOWS_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		for t_y in range(Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.y):
			for t_x in range(Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.x):
				background_scene.set_cell(cell_pos + Vector2i(t_x, t_y), Outside_Constants.ATLAS_SOURCE_ID, atlas_coords + Vector2i(t_x, t_y))
	Logger.log(self, "blue building windows line 1 placed")

	# Windows line 2
	indent = 0
	for i in range(Outside_Constants.CHUNK_TILE_WIDTH / Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.x):
		var cell_pos = Vector2i(start_x + indent, start_y + Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.y)
		indent += Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.x
		var atlas_coords = Outside_Constants.BLUE_BUILDING_WINDOWS_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		for t_y in range(Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.y):
			for t_x in range(Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.x):
				background_scene.set_cell(cell_pos + Vector2i(t_x, t_y), Outside_Constants.ATLAS_SOURCE_ID, atlas_coords + Vector2i(t_x, t_y))
	Logger.log(self, "blue building windows line 2 placed")

	# Entrances
	var x_pos = start_x + Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.x * 2
	var y_pos = start_y + Outside_Constants.BLUE_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.y
	var cell_pos = Vector2i(x_pos, y_pos)
	var atlas_coords = Outside_Constants.BLUE_BUILDING_ENTRANCE_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
	for t_y in range(Outside_Constants.BLUE_BUILDING_ENTRANCE_TILE_SIZE.y):
		for t_x in range(Outside_Constants.BLUE_BUILDING_ENTRANCE_TILE_SIZE.x):
			background_scene.set_cell(cell_pos + Vector2i(t_x, t_y), Outside_Constants.ATLAS_SOURCE_ID, atlas_coords + Vector2i(t_x, t_y))
	Logger.log(self, "entrances placed")
	Logger.log(self, "completed")


func _fill_cross_horizon(background_scene: TileMapLayer, start_x: int, start_y: int) -> void:
	Logger.log(self, "start | start_x=" + str(start_x) + " start_y=" + str(start_y))

	var sidewalk_indent = 0
	for i in range(4):
		var cell_pos = Vector2i(start_x + sidewalk_indent, start_y + (4 * Outside_Constants.SIDEWALK_BACKGROUND_TILE_SIZE.y))
		sidewalk_indent += 7 if i % 4 in [1, 3] else 1
		var atlas_coords = Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		background_scene.set_cell(cell_pos, Outside_Constants.ATLAS_SOURCE_ID, atlas_coords)

	var road_indent = 2
	for i in range(6):
		var cell_pos = Vector2i(start_x + road_indent, start_y + (4 * Outside_Constants.ROAD_BACKGROUND_TILE_SIZE.y))
		road_indent += 1
		var atlas_coords = Outside_Constants.ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		background_scene.set_cell(cell_pos, Outside_Constants.ATLAS_SOURCE_ID, atlas_coords)

	Logger.log(self, "cross horizon placed")
	Logger.log(self, "completed")


func _fill_factory_building(background_scene: TileMapLayer, start_x: int, start_y: int) -> void:
	Logger.log(self, "start factory building")

	var indent = 0
	for floor in range(2):
		indent = 0
		for i in range(Outside_Constants.CHUNK_TILE_WIDTH / Outside_Constants.FACTORY_BUILDING_WINDOWS_TILE_SIZE.x):
			var cell_pos = Vector2i(start_x + indent, start_y + (floor * Outside_Constants.FACTORY_BUILDING_WINDOWS_TILE_SIZE.y))
			indent += Outside_Constants.FACTORY_BUILDING_WINDOWS_TILE_SIZE.x
			var atlas_coords = Outside_Constants.FACTORY_BUILDING_WINDOWS_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
			for t_y in range(Outside_Constants.FACTORY_BUILDING_WINDOWS_TILE_SIZE.y):
				for t_x in range(Outside_Constants.FACTORY_BUILDING_WINDOWS_TILE_SIZE.x):
					background_scene.set_cell(cell_pos + Vector2i(t_x, t_y), Outside_Constants.ATLAS_SOURCE_ID, atlas_coords + Vector2i(t_x, t_y))
		Logger.log(self, "factory floor " + str(floor) + " windows placed")

	Logger.log(self, "completed")
