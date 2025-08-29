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

var ATLAS_SOURCE_ID = 0

var ROAD_BACKGROUND_TILE_SIZE = Vector2i(2, 3)
var ROAD_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [ Vector2i(4, 0) ]

var SIDEWALK_BACKGROUND_TILE_SIZE = Vector2i(4, 3)
var SIDEWALK_BACKGROUND_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [ Vector2i(6, 0) ]

var GRASS_BACKGROUND_TILE_SIZE = Vector2i(4, 4)
var GRASS_BACKGROUND_TILES_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [ Vector2i(0, 4) ]

var CONCRETE_BACKGROUND_TILE_SIZE = Vector2i(3, 3)
var CONCRETE_BACKGROUND_TILES_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [ Vector2i(4, 4) ]

var BLUE_BUILDING_ENTRANCE_WINDOW_TILE_SIZE = Vector2i(2, 2)
var BLUE_BUILDING_ENTRANCE_TILE_SIZE = Vector2i(2, 3)
var BLUE_BUILDING_WINDOWS_TILE_SIZE = Vector2i(2, 2)
var BLUE_BUILDING_BASEMENT_TILE_SIZE = Vector2i(2, 1)

var BLUE_BUILDING_ENTRANCE_WINDOW_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [ Vector2i(8, 8) ]
var BLUE_BUILDING_ENTRANCE_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [ Vector2i(8, 10) ] 
var BLUE_BUILDING_BASEMENT_UPPER_LEFT_CORNER_TILES_ATLAS_COORDS = [
	Vector2i(0, 12),
	Vector2i(2, 12),
	Vector2i(4, 12),
	Vector2i(6, 12),
]
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

func _ready() -> void:
	randomize()


func spawn_new_entity_at(entity: PackedScene, new_position: Vector2i, new_z_index: int = 0) -> Node2D:
	var new_entity = entity.instantiate()
	new_entity.z_index = new_z_index
	add_child(new_entity)
	new_entity.global_position = new_position
	return new_entity

# Backgound generation
func draw_chunk_background(current_chunk: int) -> void:
	pass

# Decorations generation
func draw_chunk_decorations(current_chunk: int) -> void:
	pass

# Grass generation
func draw_chunk_grass(current_chunk: int) -> void:
	var start_x = current_chunk * CHUNK_TILE_WIDTH * 16
	var start_y = 65
	
	spawn_new_entity_at(GrassScene, Vector2i(start_x, start_y))
	spawn_new_entity_at(GrassScene, Vector2i(start_x + 16 * 4, start_y))

# Environments generation
func draw_chunk_environments(current_chunk: int) -> void:
	pass
