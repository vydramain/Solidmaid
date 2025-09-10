extends Node
class_name Outside_Lower_Environment_Drawer

# Reference to the 3D layer data array from ChunkManager
var layer_data: Array[Array] = []

# Scene references for final application (used by ChunkManager)
var environment_layer_1: Node
var environment_layer_2: Node

# Preloaded scenes
var GrassScene := preload("res://resources/entity/environment/grass/Grass.tscn")
var TreeEntityScene := preload("res://resources/entity/environment/trees/Tree.tscn")

func draw_lower_environment_layer_1_to_layer_data(current_chunk_type: Outside_Constants.LOWER_CHUNK, current_chunk_index: int, layer_index: int, background_context: Array, decorations_context: Array) -> void:
	Logger.log(self, "[ENVIRONMENT_L1] Start drawing lower environment layer 1 | Type: " + str(current_chunk_type) + ", Index: " + str(current_chunk_index) + " | layer=" + str(layer_index))
	
	var start_y = 0  # Lower chunk always starts at row 0
	var start_x = current_chunk_index * Outside_Constants.CHUNK_TILE_WIDTH  # Horizontal offset by index
	
	match current_chunk_type:
		Outside_Constants.LOWER_CHUNK.GRASS:
			_fill_grass_environment_layer_1(start_x, start_y, layer_index, background_context, decorations_context)
		Outside_Constants.LOWER_CHUNK.PARK:
			_fill_park_environment_layer_1(start_x, start_y, layer_index, background_context, decorations_context)
		Outside_Constants.LOWER_CHUNK.ROAD, Outside_Constants.LOWER_CHUNK.CROSS_START, Outside_Constants.LOWER_CHUNK.CROSS_END:
			# No grass placement for road chunks
			Logger.log(self, "[ENVIRONMENT_L1] Skipping grass placement for road/cross chunk type: " + str(current_chunk_type))
		_:
			Logger.log(self, "[ENVIRONMENT_L1] Unsupported chunk type for environment layer 1: " + str(current_chunk_type))

func draw_lower_environment_layer_2_to_layer_data(current_chunk_type: Outside_Constants.LOWER_CHUNK, current_chunk_index: int, layer_index: int, background_context: Array, decorations_context: Array, env1_context: Array) -> void:
	Logger.log(self, "[ENVIRONMENT_L2] Start drawing lower environment layer 2 | Type: " + str(current_chunk_type) + ", Index: " + str(current_chunk_index) + " | layer=" + str(layer_index))
	
	var start_y = 0  # Lower chunk always starts at row 0
	var start_x = current_chunk_index * Outside_Constants.CHUNK_TILE_WIDTH  # Horizontal offset by index
	
	match current_chunk_type:
		Outside_Constants.LOWER_CHUNK.GRASS:
			_fill_grass_environment_layer_2(start_x, start_y, layer_index, background_context, decorations_context, env1_context)
		Outside_Constants.LOWER_CHUNK.PARK:
			_fill_park_environment_layer_2(start_x, start_y, layer_index, background_context, decorations_context, env1_context)
		Outside_Constants.LOWER_CHUNK.ROAD, Outside_Constants.LOWER_CHUNK.CROSS_START, Outside_Constants.LOWER_CHUNK.CROSS_END:
			# No tree placement for road chunks
			Logger.log(self, "[ENVIRONMENT_L2] Skipping tree placement for road/cross chunk type: " + str(current_chunk_type))
		_:
			Logger.log(self, "[ENVIRONMENT_L2] Unsupported chunk type for environment layer 2: " + str(current_chunk_type))

func _set_entity_in_layer_data(x: int, y: int, layer_index: int, scene: PackedScene, world_position: Vector2) -> void:
	"""Helper function to safely set entity data in the layer array"""
	if layer_index >= 0 and layer_index < layer_data.size():
		if x >= 0 and x < layer_data[layer_index].size():
			if y >= 0 and y < layer_data[layer_index][x].size():
				layer_data[layer_index][x][y] = {
					"scene": scene,
					"position": world_position,
					"sprite_type": randi() % 4  # Random grass type 0-3
				}

func _is_tile_covered_by_decoration(x: int, y: int, decorations_context: Array) -> bool:
	"""Check if a tile position is covered by decoration tiles"""
	if x >= 0 and x < decorations_context.size():
		if y >= 0 and y < decorations_context[x].size():
			return decorations_context[x][y] != null
	return false

func _is_background_tile_grass(x: int, y: int, background_context: Array) -> bool:
	"""Check if background tile at position is a grass tile"""
	if x >= 0 and x < background_context.size():
		if y >= 0 and y < background_context[x].size():
			var tile_data = background_context[x][y]
			if tile_data != null and tile_data.has("atlas_coords"):
				var atlas_coords = tile_data.atlas_coords
				# Check if atlas coordinates match grass background tiles
				for grass_coord in Outside_Constants.GRASS_BACKGROUND_TILES_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS:
					if atlas_coords.x >= grass_coord.x and atlas_coords.x < grass_coord.x + Outside_Constants.GRASS_BACKGROUND_TILE_SIZE.x:
						if atlas_coords.y >= grass_coord.y and atlas_coords.y < grass_coord.y + Outside_Constants.GRASS_BACKGROUND_TILE_SIZE.y:
							return true
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

func _fill_grass_environment_layer_1(start_x: int, start_y: int, layer_index: int, background_context: Array, decorations_context: Array) -> void:
	Logger.log(self, "[GRASS_ENV_L1] Placing grass entities | Start position: (" + str(start_x) + ", " + str(start_y) + ")")
	
	var grass_placed = 0
	var grass_skipped = 0
	
	# Only place grass on lower chunk area (grass background)
	for row in range(Outside_Constants.LOWER_CHUNK_TILE_HEIGHT, Outside_Constants.CHUNK_TILE_HEIGHT):
		for col in range(0, Outside_Constants.CHUNK_TILE_WIDTH):
			var tile_x = start_x + col
			var tile_y = start_y + row
			
			# Check if this tile has grass background
			if _is_background_tile_grass(tile_x, tile_y, background_context):
				# Check if we can place grass here (no decorations)
				if _can_place_entity_at(tile_x, tile_y, 1, 1, decorations_context):
					var world_position = Vector2(tile_x * Outside_Constants.TILE_SIZE, tile_y * Outside_Constants.TILE_SIZE)
					_set_entity_in_layer_data(tile_x, tile_y, layer_index, GrassScene, world_position)
					grass_placed += 1
				else:
					grass_skipped += 1
	
	Logger.log(self, "[GRASS_ENV_L1] Grass placement complete | Placed: " + str(grass_placed) + " | Skipped (decorations): " + str(grass_skipped))

func _find_sidewalk_lines(start_x: int, start_y: int, decorations_context: Array) -> Array:
	"""Find rows of sidewalk tiles in the decorations context for tree placement."""
	Logger.log(self, "[FIND_SIDEWALK_LINES] Searching for sidewalk lines | Start position: (" + str(start_x) + ", " + str(start_y) + ")")
	
	var sidewalk_lines: Array = []
	
	# Define the chunk area to search
	var end_x = start_x + Outside_Constants.CHUNK_TILE_WIDTH
	var end_y = start_y + Outside_Constants.CHUNK_TILE_HEIGHT
	
	# Iterate through each row in the chunk
	for y in range(start_y, end_y):
		var line_tiles: Array = []
		var is_sidewalk_row = false
		
		# Check each tile in the row
		for x in range(start_x, end_x):
			if x < decorations_context.size() and y < decorations_context[x].size():
				var tile_data = decorations_context[x][y]
				# Check if the tile is a sidewalk tile based on atlas_coords
				if tile_data != null and tile_data.has("atlas_coords"):
					var atlas_coords = tile_data.atlas_coords
					if atlas_coords in Outside_Constants.SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS:
						line_tiles.append(Vector2i(x, y))
						is_sidewalk_row = true
					else:
						# If a non-sidewalk tile is found, break the line
						if line_tiles.size() > 0:
							break
				else:
					# If no tile data or not a sidewalk, break the line
					if line_tiles.size() > 0:
						break
			else:
				# Out of bounds, break the line
				if line_tiles.size() > 0:
					break
		
		# If we found a valid sidewalk row with enough tiles, add it to the result
		if is_sidewalk_row and line_tiles.size() >= 2:  # Minimum length for a sidewalk line
			sidewalk_lines.append({
				"y_pos": y,
				"tiles": line_tiles
			})
	
	Logger.log(self, "[FIND_SIDEWALK_LINES] Found " + str(sidewalk_lines.size()) + " sidewalk lines")
	return sidewalk_lines

func _fill_park_environment_layer_1(start_x: int, start_y: int, layer_index: int, background_context: Array, decorations_context: Array) -> void:
	Logger.log(self, "[PARK_ENV_L1] Placing park grass entities | Start position: (" + str(start_x) + ", " + str(start_y) + ")")
	
	# For parks, use same logic as grass but potentially with different density
	_fill_grass_environment_layer_1(start_x, start_y, layer_index, background_context, decorations_context)

func _fill_grass_environment_layer_2(start_x: int, start_y: int, layer_index: int, background_context: Array, decorations_context: Array, env1_context: Array) -> void:
	Logger.log(self, "[GRASS_ENV_L2] Placing tree entities along sidewalk lines | Start position: (" + str(start_x) + ", " + str(start_y) + ")")
	
	# Tree dimensions: 2 tiles width, 3 tiles height
	var tree_width = 2
	var tree_height = 3
	
	var trees_placed = 0
	var trees_skipped = 0
	
	# Find sidewalk decoration lines
	var sidewalk_lines = _find_sidewalk_lines(start_x, start_y, decorations_context)
	
	if sidewalk_lines.size() == 0:
		Logger.log(self, "[GRASS_ENV_L2] No sidewalk lines found for tree placement")
		return
	
	# Place trees along each sidewalk line
	for sidewalk_line in sidewalk_lines:
		var line_tiles = sidewalk_line.tiles
		var line_y = sidewalk_line.y_pos
		
		Logger.log(self, "[GRASS_ENV_L2] Processing sidewalk line at y=" + str(line_y) + " with " + str(line_tiles.size()) + " tiles")
		
		# Place trees every 3-4 tiles along the line
		var i = 0
		while i < line_tiles.size() - tree_width + 1:
			var tile_pos = line_tiles[i]
			var tree_x = tile_pos.x
			var tree_y = line_y - tree_height + 1  # Position tree so bottom aligns with sidewalk
			
			# Check if we can place tree here (ensure it doesn't overlap with decorations or other entities)
			if _can_place_entity_at(tree_x, tree_y, tree_width, tree_height, decorations_context, env1_context):
				# Check that tree placement is within bounds
				if tree_y >= start_y and tree_y + tree_height <= start_y + Outside_Constants.CHUNK_TILE_HEIGHT:
					var world_position = Vector2(tree_x * Outside_Constants.TILE_SIZE, tree_y * Outside_Constants.TILE_SIZE)
					_set_entity_in_layer_data(tree_x, tree_y, layer_index, TreeEntityScene, world_position)
					trees_placed += 1
					
					# Skip ahead to avoid overlapping trees (spacing of 3-4 tiles)
					i += 3 + randi() % 2  # 3 or 4 tiles spacing
				else:
					trees_skipped += 1
					i += 1
			else:
				trees_skipped += 1
				i += 1
	
	Logger.log(self, "[GRASS_ENV_L2] Tree placement along sidewalks complete | Placed: " + str(trees_placed) + " | Skipped: " + str(trees_skipped))

func _fill_park_environment_layer_2(start_x: int, start_y: int, layer_index: int, background_context: Array, decorations_context: Array, env1_context: Array) -> void:
	Logger.log(self, "[PARK_ENV_L2] Placing park tree entities along sidewalk lines | Start position: (" + str(start_x) + ", " + str(start_y) + ")")
	
	# Tree dimensions: 2 tiles width, 3 tiles height
	var tree_width = 2
	var tree_height = 3
	
	var trees_placed = 0
	var trees_skipped = 0
	
	# Find sidewalk decoration lines
	var sidewalk_lines = _find_sidewalk_lines(start_x, start_y, decorations_context)
	
	if sidewalk_lines.size() == 0:
		Logger.log(self, "[PARK_ENV_L2] No sidewalk lines found for tree placement")
		return
	
	# For parks, place trees more densely along sidewalk lines
	for sidewalk_line in sidewalk_lines:
		var line_tiles = sidewalk_line.tiles
		var line_y = sidewalk_line.y_pos
		
		Logger.log(self, "[PARK_ENV_L2] Processing park sidewalk line at y=" + str(line_y) + " with " + str(line_tiles.size()) + " tiles")
		
		# Place trees every 2-3 tiles along the line (denser for parks)
		var i = 0
		while i < line_tiles.size() - tree_width + 1:
			var tile_pos = line_tiles[i]
			var tree_x = tile_pos.x
			var tree_y = line_y - tree_height + 1  # Position tree so bottom aligns with sidewalk
			
			# Check if we can place tree here
			if _can_place_entity_at(tree_x, tree_y, tree_width, tree_height, decorations_context, env1_context):
				# Check that tree placement is within bounds
				if tree_y >= start_y and tree_y + tree_height <= start_y + Outside_Constants.CHUNK_TILE_HEIGHT:
					var world_position = Vector2(tree_x * Outside_Constants.TILE_SIZE, tree_y * Outside_Constants.TILE_SIZE)
					_set_entity_in_layer_data(tree_x, tree_y, layer_index, TreeEntityScene, world_position)
					trees_placed += 1
					
					# Denser spacing for parks (2-3 tiles)
					i += 2 + randi() % 2  # 2 or 3 tiles spacing
				else:
					trees_skipped += 1
					i += 1
			else:
				trees_skipped += 1
				i += 1
	
	Logger.log(self, "[PARK_ENV_L2] Park tree placement along sidewalks complete | Placed: " + str(trees_placed) + " | Skipped: " + str(trees_skipped))
