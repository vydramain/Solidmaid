extends Node
class_name Outside_Upper_Background_Drawer

# Reference to the 3D layer data array from ChunkManager
var layer_data: Array[Array] = []

# Scene references for final application (used by ChunkManager)
var background_scene: TileMapLayer

func draw_upper_chunk_to_layer_data(current_chunk_type: Outside_Constants.UPPER_CHUNK, current_chunk_index: int, layer_index: int) -> void:
	Logger.log(self, "[DRAW CHUNK] Starting upper chunk drawing | type=" + str(current_chunk_type) + " | index=" + str(current_chunk_index) + " | layer=" + str(layer_index))
	var start_y = 0  # upper chunk always starts at row 0
	var start_x = current_chunk_index * Outside_Constants.CHUNK_TILE_WIDTH
	
	match current_chunk_type:
		Outside_Constants.UPPER_CHUNK.LIGTH_BUILDING:
			_fill_light_building_to_layer_data(start_x, start_y, layer_index)
		Outside_Constants.UPPER_CHUNK.BLUE_BUILDING:
			_fill_blue_building_to_layer_data(start_x, start_y, layer_index)
		Outside_Constants.UPPER_CHUNK.CROSS_START:
			_fill_cross_horizon_to_layer_data(start_x, start_y, layer_index)
		Outside_Constants.UPPER_CHUNK.CROSS_END:
			_fill_cross_horizon_to_layer_data(start_x, start_y, layer_index)
		Outside_Constants.UPPER_CHUNK.PARK:
			Logger.log(self, "[DRAW CHUNK] PARK chunk type not implemented yet")
		Outside_Constants.UPPER_CHUNK.FACTORY:
			_fill_factory_building_to_layer_data(start_x, start_y, layer_index)
		_:
			Logger.log(self, "[DRAW CHUNK] Unknown upper chunk type: " + str(current_chunk_type))
	
	Logger.log(self, "[DRAW CHUNK] Completed drawing upper chunk | type=" + str(current_chunk_type))

func _set_tile_in_layer_data(x: int, y: int, layer_index: int, atlas_coords: Vector2i) -> void:
	"""Helper function to safely set tile data in the layer array"""
	if layer_index >= 0 and layer_index < layer_data.size():
		if x >= 0 and x < layer_data[layer_index].size():
			if y >= 0 and y < layer_data[layer_index][x].size():
				layer_data[layer_index][x][y] = {
					"source_id": Outside_Constants.ATLAS_SOURCE_ID,
					"atlas_coords": atlas_coords
				}

func _fill_light_building_to_layer_data(start_x: int, start_y: int, layer_index: int) -> void:
	Logger.log(self, "[LIGHT BUILDING] Starting drawing at position (" + str(start_x) + ", " + str(start_y) + ")")
	
	# Basement
	for i in range(Outside_Constants.CHUNK_TILE_WIDTH / Outside_Constants.LIGHT_BUILDING_BASEMENT_TILE_SIZE.x):
		var x_pos = start_x + i * Outside_Constants.LIGHT_BUILDING_BASEMENT_TILE_SIZE.x
		var y_pos = start_y + 4
		var atlas_coords = Outside_Constants.LIGHT_BUILDING_BASEMENT_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		for t in range(Outside_Constants.LIGHT_BUILDING_BASEMENT_TILE_SIZE.x):
			_set_tile_in_layer_data(x_pos + t, y_pos, layer_index, atlas_coords + Vector2i(t, 0))
		Logger.log(self, "[LIGHT BUILDING] Basement tiles placed from x=" + str(start_x) + " to x=" + str(x_pos))
	
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
		var atlas_coords = Outside_Constants.LIGHT_BUILDING_WINDOWS_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		for t_y in range(Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.y):
			for t_x in range(Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x):
				_set_tile_in_layer_data(x_pos + t_x, y_pos + t_y, layer_index, atlas_coords + Vector2i(t_x, t_y))
	Logger.log(self, "[LIGHT BUILDING] First row of windows placed | total width covered=" + str(first_indent))
	
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
		var atlas_coords = Outside_Constants.LIGHT_BUILDING_WINDOWS_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		for t_y in range(Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.y):
			for t_x in range(Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x):
				_set_tile_in_layer_data(x_pos + t_x, y_pos + t_y, layer_index, atlas_coords + Vector2i(t_x, t_y))
	Logger.log(self, "[LIGHT BUILDING] Second row of windows placed | total width covered=" + str(second_indent))
	
	# Entrance windows
	for i in range(Outside_Constants.CHUNK_TILE_WIDTH / (Outside_Constants.LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.x + Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x * 2)):
		var x_pos = start_x + i * (Outside_Constants.LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.x + Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x * 2) + Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x
		var y_pos = start_y
		var atlas_coords = Outside_Constants.LIGHT_BUILDING_ENTRANCE_WINDOW_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		for t_y in range(Outside_Constants.LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.y):
			for t_x in range(Outside_Constants.LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.x):
				_set_tile_in_layer_data(x_pos + t_x, y_pos + t_y, layer_index, atlas_coords + Vector2i(t_x, t_y))
	Logger.log(self, "[LIGHT BUILDING] Entrance windows placed along chunk width")
	
	# Entrances
	for i in range(Outside_Constants.CHUNK_TILE_WIDTH / (Outside_Constants.LIGHT_BUILDING_ENTRANCE_TILE_SIZE.x + Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x * 2)):
		var x_pos = start_x + i * (Outside_Constants.LIGHT_BUILDING_ENTRANCE_TILE_SIZE.x + Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x * 2) + Outside_Constants.LIGHT_BUILDING_WINDOWS_TILE_SIZE.x
		var y_pos = start_y + Outside_Constants.LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.y
		var atlas_coords = Outside_Constants.LIGHT_BUILDING_ENTRANCE_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		for t_y in range(Outside_Constants.LIGHT_BUILDING_ENTRANCE_TILE_SIZE.y):
			for t_x in range(Outside_Constants.LIGHT_BUILDING_ENTRANCE_TILE_SIZE.x):
				_set_tile_in_layer_data(x_pos + t_x, y_pos + t_y, layer_index, atlas_coords + Vector2i(t_x, t_y))
	Logger.log(self, "[LIGHT BUILDING] Entrances placed along chunk width")
	Logger.log(self, "[LIGHT BUILDING] Completed drawing light building")

func _fill_blue_building_to_layer_data(start_x: int, start_y: int, layer_index: int) -> void:
	Logger.log(self, "[BLUE BUILDING] Starting drawing at position (" + str(start_x) + ", " + str(start_y) + ")")

	# Basement
	for i in range(Outside_Constants.CHUNK_TILE_WIDTH / Outside_Constants.BLUE_BUILDING_BASEMENT_TILE_SIZE.x):
		var x_pos = start_x + i * Outside_Constants.BLUE_BUILDING_BASEMENT_TILE_SIZE.x
		var y_pos = start_y + 4
		var atlas_coords = Outside_Constants.BLUE_BUILDING_BASEMENT_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		for t in range(Outside_Constants.BLUE_BUILDING_BASEMENT_TILE_SIZE.x):
			_set_tile_in_layer_data(x_pos + t, y_pos, layer_index, atlas_coords + Vector2i(t, 0))
		Logger.log(self, "[BLUE BUILDING] Basement tiles placed from x=" + str(start_x) + " to x=" + str(x_pos))

	# Windows line 1
	var indent = 0
	for i in range(Outside_Constants.CHUNK_TILE_WIDTH / Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.x):
		var x_pos = start_x + indent
		var y_pos = start_y
		indent += Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.x
		var atlas_coords = Outside_Constants.BLUE_BUILDING_WINDOWS_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		for t_y in range(Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.y):
			for t_x in range(Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.x):
				_set_tile_in_layer_data(x_pos + t_x, y_pos + t_y, layer_index, atlas_coords + Vector2i(t_x, t_y))
	Logger.log(self, "[BLUE BUILDING] Windows line 1 placed, total width covered=" + str(indent))

	# Windows line 2
	indent = 0
	for i in range(Outside_Constants.CHUNK_TILE_WIDTH / Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.x):
		var x_pos = start_x + indent
		var y_pos = start_y + Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.y
		indent += Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.x
		var atlas_coords = Outside_Constants.BLUE_BUILDING_WINDOWS_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		for t_y in range(Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.y):
			for t_x in range(Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.x):
				_set_tile_in_layer_data(x_pos + t_x, y_pos + t_y, layer_index, atlas_coords + Vector2i(t_x, t_y))
	Logger.log(self, "[BLUE BUILDING] Windows line 2 placed, total width covered=" + str(indent))

	# Entrance windows (placed over existing windows at specific position)
	var x_pos = start_x + Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.x * 2
	var y_pos = start_y
	var atlas_coords = Outside_Constants.BLUE_BUILDING_ENTRANCE_WINDOW_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
	for t_y in range(Outside_Constants.BLUE_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.y):
		for t_x in range(Outside_Constants.BLUE_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.x):
			_set_tile_in_layer_data(x_pos + t_x, y_pos + t_y, layer_index, atlas_coords + Vector2i(t_x, t_y))
	Logger.log(self, "[BLUE BUILDING] Entrance windows placed at x=" + str(x_pos) + ", y=" + str(y_pos))

	# Entrances
	x_pos = start_x + Outside_Constants.BLUE_BUILDING_WINDOWS_TILE_SIZE.x * 2
	y_pos = start_y + Outside_Constants.BLUE_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.y
	atlas_coords = Outside_Constants.BLUE_BUILDING_ENTRANCE_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
	for t_y in range(Outside_Constants.BLUE_BUILDING_ENTRANCE_TILE_SIZE.y):
		for t_x in range(Outside_Constants.BLUE_BUILDING_ENTRANCE_TILE_SIZE.x):
			_set_tile_in_layer_data(x_pos + t_x, y_pos + t_y, layer_index, atlas_coords + Vector2i(t_x, t_y))
	Logger.log(self, "[BLUE BUILDING] Entrances placed at x=" + str(x_pos) + ", y=" + str(y_pos))
	Logger.log(self, "[BLUE BUILDING] Completed drawing blue building")

func _fill_cross_horizon_to_layer_data(start_x: int, start_y: int, layer_index: int) -> void:
	Logger.log(self, "[CROSS HORIZON] Starting drawing at position (" + str(start_x) + ", " + str(start_y) + ")")

	# Sidewalk tiles
	var sidewalk_indent = 0
	for i in range(4):
		var x_pos = start_x + sidewalk_indent
		var y_pos = start_y + (4 * Outside_Constants.SIDEWALK_BACKGROUND_TILE_SIZE.y)
		sidewalk_indent += 7 if i % 4 in [1, 3] else 1
		var atlas_coords = Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)

	# Road tiles
	var road_indent = 2
	for i in range(6):
		var x_pos = start_x + road_indent
		var y_pos = start_y + (4 * Outside_Constants.ROAD_BACKGROUND_TILE_SIZE.y)
		road_indent += 1
		var atlas_coords = Outside_Constants.ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
		_set_tile_in_layer_data(x_pos, y_pos, layer_index, atlas_coords)

	Logger.log(self, "[CROSS HORIZON] Sidewalk and road tiles placed")
	Logger.log(self, "[CROSS HORIZON] Completed drawing cross horizon")

func _fill_factory_building_to_layer_data(start_x: int, start_y: int, layer_index: int) -> void:
	Logger.log(self, "[FACTORY BUILDING] Starting drawing factory building at position (" + str(start_x) + ", " + str(start_y) + ")")

	# Factory windows across 2 floors
	for floor in range(2):
		var indent = 0
		for i in range(Outside_Constants.CHUNK_TILE_WIDTH / Outside_Constants.FACTORY_BUILDING_WINDOWS_TILE_SIZE.x):
			var x_pos = start_x + indent
			var y_pos = start_y + (floor * Outside_Constants.FACTORY_BUILDING_WINDOWS_TILE_SIZE.y)
			indent += Outside_Constants.FACTORY_BUILDING_WINDOWS_TILE_SIZE.x
			var atlas_coords = Outside_Constants.FACTORY_BUILDING_WINDOWS_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.pick_random()
			for t_y in range(Outside_Constants.FACTORY_BUILDING_WINDOWS_TILE_SIZE.y):
				for t_x in range(Outside_Constants.FACTORY_BUILDING_WINDOWS_TILE_SIZE.x):
					_set_tile_in_layer_data(x_pos + t_x, y_pos + t_y, layer_index, atlas_coords + Vector2i(t_x, t_y))
		Logger.log(self, "[FACTORY BUILDING] Floor " + str(floor) + " windows placed | total width covered=" + str(indent))

	Logger.log(self, "[FACTORY BUILDING] Completed drawing factory building")
