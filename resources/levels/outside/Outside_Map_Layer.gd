extends Node2D

var GrassScene := preload("res://resources/entity/environment/grass/Grass.tscn")
var TreeEntityScene := preload("res://resources/entity/environment/trees/Tree.tscn")

@onready var BACKGROUND_SCENE: TileMapLayer = $Background
@onready var DECORATIONS_SCENE: TileMapLayer = $Decorations
@onready var ENVIRONMENT_SCENE: TileMapLayer = $Environment

var TILE_SIZE: int = 8
var CHUNK_TILE_WIDTH: int = 20
var CHUNK_TILE_HEIGHT: int = 26
var UPPER_CHUNK_TILE_HEIGHT: int = 14
var LOWER_CHUNK_TILE_HEIGHT: int = 12

enum UPPER_CHUNK { LIGTH_BUILDING = 0, BLUE_BUILDING = 1, CROSS = 2, PARK = 3, FACTORY = 4}
enum LOWER_CHUNK { GRASS = 0, ROAD = 1 }

var POSSIBLE_UPPER_CHUNK_BASED_ON_LOWER = {
	LOWER_CHUNK.GRASS: [UPPER_CHUNK.LIGTH_BUILDING, UPPER_CHUNK.BLUE_BUILDING],
	LOWER_CHUNK.ROAD: [UPPER_CHUNK.LIGTH_BUILDING, UPPER_CHUNK.BLUE_BUILDING, UPPER_CHUNK.CROSS, UPPER_CHUNK.FACTORY],
}

var LOWER_CHUNK_DECORATION_GRASS_TILE_HEIGHT: int = 2
var LOWER_CHUNK_DECORATION_GRASS_START_Y_TILE_IDX: int = 5

var UPPER_CHUNK_DECORATION_GRASS_START_Y_TILE_IDX: int = 8
var UPPER_CHUNK_DECORATION_GRASS_START_X_TILE_IDX: int = 9

var LOWER_CHUNK_DECORATION_ROAD_START_Y_TILE_IDX: int = 9

var UPPER_CHUNK_DECORATION_CROSS

var MAX_CHUNKS: int = 10

var ATLAS_SOURCE_ID = 2

var ROAD_BACKGROUND_TILE_SIZE = Vector2i(2, 3)
var ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [ Vector2i(4, 0) ]

var SIDEWALK_BACKGROUND_TILE_SIZE = Vector2i(4, 3)
var SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [ Vector2i(6, 0) ]

var GRASS_BACKGROUND_TILE_SIZE = Vector2i(4, 4)
var GRASS_BACKGROUND_TILES_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [ Vector2i(0, 4) ]

var CONCRETE_BACKGROUND_TILE_SIZE = Vector2i(3, 3)
var CONCRETE_BACKGROUND_TILES_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [ Vector2i(4, 4) ]

var BLUE_BUILDING_ENTRANCE_WINDOW_TILE_SIZE = Vector2i(2, 2)
var BLUE_BUILDING_ENTRANCE_WINDOW_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [ Vector2i(8, 8) ]

var BLUE_BUILDING_ENTRANCE_TILE_SIZE = Vector2i(2, 3)
var BLUE_BUILDING_ENTRANCE_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [ Vector2i(8, 10) ] 

var BLUE_BUILDING_BASEMENT_TILE_SIZE = Vector2i(2, 1)
var BLUE_BUILDING_BASEMENT_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [
	Vector2i(0, 12),
	Vector2i(2, 12),
	Vector2i(4, 12),
	Vector2i(6, 12),
]

var BLUE_BUILDING_WINDOWS_TILE_SIZE = Vector2i(2, 2)
var BLUE_BUILDING_WINDOWS_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [
	Vector2i(0, 8),
	Vector2i(2, 8),
	Vector2i(4, 8),
	Vector2i(6, 8),
	Vector2i(0, 10),
	Vector2i(2, 10),
	Vector2i(4, 10),
	Vector2i(6, 10),
]

var LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE = Vector2i(2, 2)
var LIGHT_BUILDING_ENTRANCE_WINDOW_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [ Vector2i(18, 8) ]

var LIGHT_BUILDING_ENTRANCE_TILE_SIZE = Vector2i(2, 3)
var LIGHT_BUILDING_ENTRANCE_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [ Vector2i(18, 10) ] 

var LIGHT_BUILDING_BASEMENT_TILE_SIZE = Vector2i(2, 1)
var LIGHT_BUILDING_BASEMENT_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [
	Vector2i(10, 12),
	Vector2i(12, 12),
	Vector2i(14, 12),
	Vector2i(16, 12),
]

var LIGHT_BUILDING_WINDOWS_TILE_SIZE = Vector2i(4, 2)
var LIGHT_BUILDING_WINDOWS_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [
	Vector2i(10, 8),
	Vector2i(14, 8),
	Vector2i(10, 10),
	Vector2i(14, 10),
]

var FACTORY_BUILDING_ENTRANCE_TILE_SIZE = Vector2i(9, 3)
var Factory_BUILDING_ENTRACE_UPPER_LEFT_CORNER_TILES_ATLAS_COODS = [
	Vector2i(0, 13),
	Vector2i(10, 13)
]

var FACTORY_BUILDING_WINDOWS_TILE_SIZE = Vector2i(5, 3)
var FACTORY_BUILDING_WINDOWS_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [
	Vector2i(0, 16),
	Vector2i(5, 16),
	Vector2i(10, 16),
	Vector2i(15, 16),
]


# ---- helper logger ---------------------------------------------------------
func _log(msg: String) -> void:
	var current_scene_node = get_tree().current_scene
	var scene_name: String = str(current_scene_node.name) if current_scene_node != null else "NO_CURRENT_SCENE"
	var place: String = str(get_path())
	print("[" + scene_name + " | " + place + "] " + msg)
# ---------------------------------------------------------------------------


func _ready() -> void:
	_log("_ready - start")
	randomize()
	
	_log("_ready - drawing initial upper chunk: LIGHT_BUILDING at index 0")
	draw_upper_chunk_background(UPPER_CHUNK.LIGTH_BUILDING, 0)
	
	#_log("_ready - drawing initial lower chunk: GRASS at index 0")
	#draw_lower_chunk_background(LOWER_CHUNK.GRASS, 0)
	
	_log("_ready - completed initial drawing")


func spawn_new_entity_at(entity: PackedScene, new_position: Vector2i, new_z_index: int = 0) -> Node2D:
	_log("spawn_new_entity_at - requested: scene=" + str(entity) + " pos=" + str(new_position) + " z=" + str(new_z_index))
	var new_entity = entity.instantiate()
	new_entity.z_index = new_z_index
	add_child(new_entity)
	# ensure position is a Vector2 for Node2D
	new_entity.global_position = Vector2(new_position.x, new_position.y)
	_log("spawn_new_entity_at - spawned: " + str(new_entity) + " global_pos=" + str(new_entity.global_position))
	return new_entity


func draw_chunk(current_chunk_index: int) -> void:
	_log("draw_chunk - start for index: " + str(current_chunk_index))
	
	var upper_chunk_values = UPPER_CHUNK.values()
	var upper_chunk_type = upper_chunk_values[randi() % upper_chunk_values.size()]
	_log("draw_chunk - picked upper_chunk_type: " + str(upper_chunk_type))
	
	var lower_chunk_values = LOWER_CHUNK.values()
	var lower_chunk_type = lower_chunk_values[randi() % lower_chunk_values.size()]
	_log("draw_chunk - picked lower_chunk_type: " + str(lower_chunk_type))
	
	draw_upper_chunk_background(upper_chunk_type, current_chunk_index)
	draw_lower_chunk_background(lower_chunk_type, current_chunk_index)
	_log("draw_chunk - completed for index: " + str(current_chunk_index))


# Background generation
func draw_upper_chunk_background(current_chunk_type: UPPER_CHUNK, current_chunk_index: int) -> void:
	_log("draw_upper_chunk_background - start | type=" + str(current_chunk_type) + " index=" + str(current_chunk_index))
	var start_y = 0  # upper chunk always starts at row 0
	var start_x = current_chunk_index * CHUNK_TILE_WIDTH  # offset horizontally by index
	
	match current_chunk_type:
		UPPER_CHUNK.LIGTH_BUILDING:
			_log("draw_upper_chunk_background -> LIGTH_BUILDING")
			_fill_light_building(start_x, start_y)
		UPPER_CHUNK.BLUE_BUILDING:
			_log("draw_upper_chunk_background -> BLUE_BUILDING not implemented")
		UPPER_CHUNK.CROSS:
			_log("draw_upper_chunk_background -> CROSS not implemented")
		UPPER_CHUNK.PARK:
			_log("draw_upper_chunk_background -> PARK not implemented")
		UPPER_CHUNK.FACTORY:
			_log("draw_upper_chunk_background -> FACTORY not implemented")
	
	_log("draw_upper_chunk_background - completed | type=" + str(current_chunk_type))


func _fill_light_building(start_x: int, start_y: int) -> void:
	_log("_fill_light_building - start | start_x=" + str(start_x) + " start_y=" + str(start_y))
	
	# Drawing basement (tile coords, not pixels)
	for i in range(0, CHUNK_TILE_WIDTH / LIGHT_BUILDING_BASEMENT_TILE_SIZE.x):
		var x_pos = start_x + (i * LIGHT_BUILDING_BASEMENT_TILE_SIZE.x)         # Next x position depends on basement legth
		var y_pos = start_y + 4                                                 # Basement position are same for all chunks
		var cell_pos = Vector2i(x_pos, y_pos)                                   # Tile coordinates based on each chunk
		var atlas_coords_index = randi() % LIGHT_BUILDING_BASEMENT_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()
		var atlas_coords_of_tile = LIGHT_BUILDING_BASEMENT_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[atlas_coords_index]
		for t in LIGHT_BUILDING_BASEMENT_TILE_SIZE.x:
			BACKGROUND_SCENE.set_cell(cell_pos + Vector2i(t, 0), ATLAS_SOURCE_ID, atlas_coords_of_tile + Vector2i(t, 0))
		
	_log("_fill_light_building - basement tiles placed: count=" + str(CHUNK_TILE_WIDTH))
	
	# Drawing first line of windows
	var first_windows_indent = 0
	for i in range(0, CHUNK_TILE_WIDTH / (LIGHT_BUILDING_WINDOWS_TILE_SIZE.x + (LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.x * 0.5))):
		var x_pos = start_x + first_windows_indent
		var y_pos = start_y + (0 * LIGHT_BUILDING_WINDOWS_TILE_SIZE.y)
		
		if i % 2 == 0:
			first_windows_indent += (LIGHT_BUILDING_WINDOWS_TILE_SIZE.x + LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.x)
		else:
			first_windows_indent += (LIGHT_BUILDING_WINDOWS_TILE_SIZE.x)
		
		var cell_pos = Vector2i(x_pos, y_pos)
		var atlas_coords_index = randi() % LIGHT_BUILDING_WINDOWS_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()
		var atlas_coords_of_tile = LIGHT_BUILDING_WINDOWS_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[atlas_coords_index]
		for t_y in LIGHT_BUILDING_WINDOWS_TILE_SIZE.y:
			for t_x in LIGHT_BUILDING_WINDOWS_TILE_SIZE.x:
				BACKGROUND_SCENE.set_cell(cell_pos + Vector2i(t_x, t_y), ATLAS_SOURCE_ID, atlas_coords_of_tile + Vector2i(t_x, t_y))
		
	_log("_fill_light_building - first line of window tiles placed: count=" + str(CHUNK_TILE_WIDTH))
	
	# Drawing second line of windows
	var second_windows_indent = 0
	for i in range(0, CHUNK_TILE_WIDTH / (LIGHT_BUILDING_WINDOWS_TILE_SIZE.x + (LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.x * 0.5))):
		var x_pos = start_x + second_windows_indent
		var y_pos = start_y + (1 * LIGHT_BUILDING_WINDOWS_TILE_SIZE.y)
		
		if i % 2 == 0:
			second_windows_indent += (LIGHT_BUILDING_WINDOWS_TILE_SIZE.x + LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.x)
		else:
			second_windows_indent += (LIGHT_BUILDING_WINDOWS_TILE_SIZE.x)
		
		var cell_pos = Vector2i(x_pos, y_pos)
		var atlas_coords_index = randi() % LIGHT_BUILDING_WINDOWS_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()
		var atlas_coords_of_tile = LIGHT_BUILDING_WINDOWS_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[atlas_coords_index]
		for t_y in LIGHT_BUILDING_WINDOWS_TILE_SIZE.y:
			for t_x in LIGHT_BUILDING_WINDOWS_TILE_SIZE.x:
				BACKGROUND_SCENE.set_cell(cell_pos + Vector2i(t_x, t_y), ATLAS_SOURCE_ID, atlas_coords_of_tile + Vector2i(t_x, t_y))
		
	_log("_fill_light_building - second line of window tiles placed: count=" + str(CHUNK_TILE_WIDTH))
	
	# Drawing windows entrances
	for i in range(0, CHUNK_TILE_WIDTH / (LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.x + (LIGHT_BUILDING_WINDOWS_TILE_SIZE.x * 2))):
		var x_pos = start_x + (i * (LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.x + (LIGHT_BUILDING_WINDOWS_TILE_SIZE.x * 2))) + LIGHT_BUILDING_WINDOWS_TILE_SIZE.x
		var y_pos = start_y + (0 * LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.y)
		var cell_pos = Vector2i(x_pos, y_pos)
		var atlas_coords_index = randi() % LIGHT_BUILDING_ENTRANCE_WINDOW_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()
		var atlas_coords_of_tile = LIGHT_BUILDING_ENTRANCE_WINDOW_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[atlas_coords_index]
		for t_y in LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.y:
			for t_x in LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.x:
				BACKGROUND_SCENE.set_cell(cell_pos + Vector2i(t_x, t_y), ATLAS_SOURCE_ID, atlas_coords_of_tile + Vector2i(t_x, t_y))
		
	_log("_fill_light_building - windows entrances tiles placed: count=" + str(CHUNK_TILE_WIDTH))
	
	# Drawing entrances
	var entrances_indent
	for i in range(0, CHUNK_TILE_WIDTH / (LIGHT_BUILDING_ENTRANCE_TILE_SIZE.x + (LIGHT_BUILDING_WINDOWS_TILE_SIZE.x * 2))):
		var x_pos = start_x + (i * (LIGHT_BUILDING_ENTRANCE_TILE_SIZE.x + (LIGHT_BUILDING_WINDOWS_TILE_SIZE.x * 2))) + LIGHT_BUILDING_WINDOWS_TILE_SIZE.x
		var y_pos = start_y + (1 * LIGHT_BUILDING_ENTRANCE_WINDOW_TILE_SIZE.y)
		var cell_pos = Vector2i(x_pos, y_pos)
		var atlas_coords_index = randi() % LIGHT_BUILDING_ENTRANCE_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS.size()
		var atlas_coords_of_tile = LIGHT_BUILDING_ENTRANCE_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS[atlas_coords_index]
		for t_y in LIGHT_BUILDING_ENTRANCE_TILE_SIZE.y:
			for t_x in LIGHT_BUILDING_ENTRANCE_TILE_SIZE.x:
				BACKGROUND_SCENE.set_cell(cell_pos + Vector2i(t_x, t_y), ATLAS_SOURCE_ID, atlas_coords_of_tile + Vector2i(t_x, t_y))
		
	_log("_fill_light_building - entrances tiles placed: count=" + str(CHUNK_TILE_WIDTH))
	
	_log("_fill_light_building - completed")


func draw_lower_chunk_background(current_chunk_type: LOWER_CHUNK, current_chunk_index: int) -> void:
	_log("draw_lower_chunk_background - start | type=" + str(current_chunk_type) + " index=" + str(current_chunk_index))
	# TODO: Implementation pending
	_log("draw_lower_chunk_background - not implemented yet")
	pass


# Decorations generation
func draw_chunk_decorations(current_chunk: int) -> void:
	_log("draw_chunk_decorations - start | index=" + str(current_chunk))
	# TODO: Implementation pending
	_log("draw_chunk_decorations - not implemented yet")
	pass


# Grass generation
func draw_chunk_grass(current_chunk: int) -> void:
	_log("draw_chunk_grass - start | index=" + str(current_chunk))
	var start_x = current_chunk * CHUNK_TILE_WIDTH * 16
	var start_y = 65
	
	spawn_new_entity_at(GrassScene, Vector2i(start_x, start_y))
	spawn_new_entity_at(GrassScene, Vector2i(start_x + 16 * 4, start_y))
	_log("draw_chunk_grass - grass entities spawned for chunk " + str(current_chunk))


# Environments generation
func draw_chunk_environments(current_chunk: int) -> void:
	_log("draw_chunk_environments - start | index=" + str(current_chunk))
	# TODO: Implementation pending
	_log("draw_chunk_environments - not implemented yet")
	pass
