extends Node2D

var TreeEntity := preload("res://resources/entity/environment/Trees/Tree.tscn")

@onready var BACKGROUND_SCENE: TileMapLayer = $Background
@onready var GRASS_SCENE: TileMapLayer = $Grass
@onready var ENVIRONMENT_SCENE: TileMapLayer = $Environment
@onready var DECORATIONS_SCENE: TileMapLayer = $Decorations

@export var TILE_SIZE: int = 8
@export var CHUNK_WIDTH: int = 8
@export var CHUNK_HEIGHT: int = 24

@export var CHUNK_WIDTH_FOR_WALLS: int = 8
@export var CHUNK_HEIGHT_FOR_WALLS: int = 4
@export var CHUNK_WIDTH_FOR_BASEMENT_WALLS: int = 8
@export var CHUNK_HEIGHT_FOR_BASEMENT_WALLS: int = 1
@export var CHUNK_WIDTH_FOR_GRASS: int = 8
@export var CHUNK_HEIGHT_FOR_GRASS: int = 12

@export var CHUNK_WIDTH_FOR_DECORATIONS: int = 8
@export var CHUNK_HEIGHT_FOR_DECORATIONS: int = 3

@export var CHUNK_WIDTH_FOR_ENVIRONMENTS: int = 8
@export var CHUNK_HEIGHT_FOR_ENVIRONMENTS: int = 1

@export var MAX_CHUNKS: int = 10

@export var BACKGROUND_MAP_ATLAS_SOURCE_ID = 0
@export var BACKGROUND_WALLS_ATLAS_SOURCE_ID = 1
@export var DECORATIONS_ATLAS_SOURCE_ID = 0


var BACKGROUND_WALL_PATTERNS = [
	Vector2i(0, 0),
	Vector2i(2, 0),
	Vector2i(4, 0),
	Vector2i(6, 0),
	Vector2i(0, 2),
	Vector2i(2, 2),
	Vector2i(4, 2),
	Vector2i(6, 2),
]

var BACKGROUND_BASEMENT_PATTERNS = [
	Vector2i(0, 4),
	Vector2i(2, 4),
	Vector2i(4, 4),
	Vector2i(6, 4),
]


func _ready() -> void:
	randomize()
	
	for i in range(MAX_CHUNKS):
		draw_chunk_background(i)
		draw_chunk_decorations(i)
		draw_chunk_environments(i)

func spawn_new_entity_at(entity: PackedScene, new_position: Vector2i) -> Node2D:
	var new_entity = entity.instantiate()
	add_child(new_entity)
	new_entity.global_position = new_position
	return new_entity

# Backgound generation
func draw_chunk_background(current_chunk: int) -> void:
	var start_x = current_chunk * CHUNK_WIDTH
	
	## Background walls generation
	var start_y_for_walls = 0
	for x in range(0, CHUNK_WIDTH_FOR_WALLS, 2):
		for y in range(0, CHUNK_HEIGHT_FOR_WALLS, 2):
			var top_left = BACKGROUND_WALL_PATTERNS[randi() % BACKGROUND_WALL_PATTERNS.size()]
			var coords = Vector2i(start_x + x, y)
			
			# stamp 2x2 
			BACKGROUND_SCENE.set_cell(coords + Vector2i(0, 0), BACKGROUND_WALLS_ATLAS_SOURCE_ID, top_left)
			BACKGROUND_SCENE.set_cell(coords + Vector2i(1, 0), BACKGROUND_WALLS_ATLAS_SOURCE_ID, top_left + Vector2i(1, 0))
			BACKGROUND_SCENE.set_cell(coords + Vector2i(0, 1), BACKGROUND_WALLS_ATLAS_SOURCE_ID, top_left + Vector2i(0, 1))
			BACKGROUND_SCENE.set_cell(coords + Vector2i(1, 1), BACKGROUND_WALLS_ATLAS_SOURCE_ID, top_left + Vector2i(1, 1))
	
	## Background basementwalls generation
	var start_y_for_basement_walls = CHUNK_HEIGHT_FOR_WALLS
	for x in range(0, CHUNK_WIDTH_FOR_BASEMENT_WALLS, 2):
		for y in range(0, CHUNK_HEIGHT_FOR_BASEMENT_WALLS, 2):
			var top_left = BACKGROUND_BASEMENT_PATTERNS[randi() % BACKGROUND_BASEMENT_PATTERNS.size()]
			var coords = Vector2i(start_x + x, start_y_for_basement_walls + y)
			
			BACKGROUND_SCENE.set_cell(coords, BACKGROUND_WALLS_ATLAS_SOURCE_ID, top_left)
			BACKGROUND_SCENE.set_cell(coords + Vector2i(1, 0), BACKGROUND_WALLS_ATLAS_SOURCE_ID, top_left + Vector2i(1, 0))
	
	## Background grass generation
	var start_y_for_grass_walls = CHUNK_HEIGHT_FOR_WALLS + CHUNK_HEIGHT_FOR_BASEMENT_WALLS
	for x in range(CHUNK_WIDTH_FOR_GRASS):
		for y in range(CHUNK_HEIGHT_FOR_GRASS):
			var coords = Vector2i(start_x + x, start_y_for_grass_walls + y)
			var atlas_coords = Vector2i(randi() % 4 + 4, randi() % 4)
			
			BACKGROUND_SCENE.set_cell(coords, BACKGROUND_MAP_ATLAS_SOURCE_ID, atlas_coords)

# Decorations generation
func draw_chunk_decorations(current_chunk: int) -> void:
	var start_x = current_chunk * CHUNK_WIDTH
	
	var start_y_for_decorations = 6
	for x in range(CHUNK_WIDTH_FOR_DECORATIONS):
		for y in range(CHUNK_HEIGHT_FOR_DECORATIONS):
			var top_left = Vector2i(randi() % 3, randi() % 3)
			var coords = Vector2i(start_x + x, start_y_for_decorations + y)
			
			DECORATIONS_SCENE.set_cell(coords + Vector2i(0, 0), DECORATIONS_ATLAS_SOURCE_ID, top_left)

func draw_chunk_environments(current_chunk: int) -> void:
	var tile_position_index_1 = randi() % CHUNK_WIDTH_FOR_ENVIRONMENTS
	var tile_position_index_2 = randi() % CHUNK_WIDTH_FOR_ENVIRONMENTS
	var start_x = (current_chunk + 1) * CHUNK_WIDTH * 16
	var start_y = 64
	var random_tile_position_1 = -16 * tile_position_index_1
	var random_tile_position_2 = -16 * tile_position_index_2
	
	for x in range(CHUNK_WIDTH_FOR_ENVIRONMENTS):
		if randi() % 4 == random_tile_position_1 % 4:
			spawn_new_entity_at(TreeEntity, Vector2i(start_x + random_tile_position_1, start_y))
			spawn_new_entity_at(TreeEntity, Vector2i(start_x + random_tile_position_1, start_y + 72))
		if randi() % 4 == random_tile_position_2 % 4:
			spawn_new_entity_at(TreeEntity, Vector2i(start_x + random_tile_position_2, start_y))
			spawn_new_entity_at(TreeEntity, Vector2i(start_x + random_tile_position_2, start_y + 72))
