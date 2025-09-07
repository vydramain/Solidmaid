extends Node
class_name Outside_Lower_Environment_Drawer

var environment_layer_1: Node2D  # For non-collision objects (grass)
var environment_layer_2: Node2D  # For collision/interactive objects (trees)

## Environment configuration data class
class EnvironmentConfig:
	var density: float = 0.15
	var min_spacing: int = 2
	var position_variance: float = 0
	var rotation_variance: float = 0
	var scene_path: String = ""
	var layer_priority: int = 0  # 0 = layer_1 (no collision), 1 = layer_2 (collision)
	
	func _init(p_density: float = 0.15, p_scene_path: String = "", p_min_spacing: int = 2, p_layer: int = 0):
		density = p_density
		scene_path = p_scene_path
		min_spacing = p_min_spacing
		layer_priority = p_layer

## Environment placement strategy interface
class PlacementStrategy:
	var _rng: RandomNumberGenerator
	var _placed_positions: Dictionary = {}  # Separate tracking per layer
	
	func _init(seed_value: int = -1):
		_rng = RandomNumberGenerator.new()
		if seed_value != -1:
			_rng.seed = seed_value
		else:
			_rng.randomize()
		_placed_positions[0] = []  # Layer 1 positions
		_placed_positions[1] = []  # Layer 2 positions
	
	func can_place_at(col: int, row: int, config: EnvironmentConfig) -> bool:
		var current_pos = Vector2(col, row)
		var layer_positions = _placed_positions.get(config.layer_priority, [])
		
		for placed_pos in layer_positions:
			if current_pos.distance_to(placed_pos) < config.min_spacing:
				return false
		return true
	
	func place_objects_in_area(start_x: int, start_y: int, width: int, height: int, 
							   config: EnvironmentConfig, target_parent: Node2D) -> int:
		# Clear positions for this layer
		if not _placed_positions.has(config.layer_priority):
			_placed_positions[config.layer_priority] = []
		_placed_positions[config.layer_priority].clear()
		
		var placed_count: int = 0
		var scene_resource = load(config.scene_path) as PackedScene
		
		if not scene_resource:
			Logger.log(target_parent, "[PLACEMENT_ERROR] Failed to load scene resource: " + config.scene_path)
			return 0
		
		if not target_parent:
			Logger.log(self, "[PLACEMENT_ERROR] Target parent node is null for layer " + str(config.layer_priority))
			return 0
		
		Logger.log(target_parent, "[PLACEMENT_START] Layer " + str(config.layer_priority) + " | Area: (" + str(start_x) + "," + str(start_y) + ") " + str(width) + "x" + str(height) + " | Scene: " + config.scene_path)
		
		for row in range(height):
			for col in range(width):
				if _should_place_object(col, row, config):
					var world_pos = _calculate_world_position(start_x + col, start_y + row, config)
					_instantiate_object(scene_resource, world_pos, target_parent, config)
					_placed_positions[config.layer_priority].append(Vector2(col, row))
					placed_count += 1
		
		Logger.log(target_parent, "[PLACEMENT_COMPLETE] Layer " + str(config.layer_priority) + " | Placed " + str(placed_count) + " objects")
		return placed_count
	
	func _should_place_object(col: int, row: int, config: EnvironmentConfig) -> bool:
		return _rng.randf() <= config.density and can_place_at(col, row, config)
	
	func _calculate_world_position(tile_x: int, tile_y: int, config: EnvironmentConfig) -> Vector2:
		var tile_size: int = Outside_Constants.TILE_SIZE if "TILE_SIZE" in Outside_Constants else 32
		var base_pos = Vector2(tile_x * tile_size, tile_y * tile_size)
		
		if config.position_variance > 0:
			var variance = tile_size * config.position_variance
			base_pos += Vector2(
				_rng.randf_range(-variance, variance),
				_rng.randf_range(-variance, variance)
			)
		
		return base_pos
	
	func _instantiate_object(scene: PackedScene, position: Vector2, parent: Node2D, config: EnvironmentConfig) -> void:
		if not parent:
			Logger.log(self, "[INSTANTIATION_ERROR] Parent node is null!")
			return
			
		var instance = scene.instantiate()
		instance.global_position = position
		
		if config.rotation_variance > 0:
			instance.rotation = _rng.randf_range(-PI * config.rotation_variance, PI * config.rotation_variance)
		
		parent.add_child(instance)
		Logger.log(self, "[OBJECT_PLACED] " + scene.resource_path.get_file() + " at " + str(position) + " on layer " + str(config.layer_priority))

## Main environment drawer class
@export var use_fixed_seed: bool = false
@export var generation_seed: int = 12345

var _tree_config: EnvironmentConfig
var _grass_config: EnvironmentConfig
var _placement_strategy: PlacementStrategy

func _ready() -> void:
	Logger.log(self, "[INIT] Initializing Outside Lower Environment Drawer")
	_initialize_configs()
	_initialize_placement_strategy()
	_validate_environment_layers()
	Logger.log(self, "[INIT] Environment drawer initialization complete")

func _initialize_configs() -> void:
	Logger.log(self, "[CONFIG] Initializing environment configurations")
	
	# Trees go to layer 2 (collision/interaction layer)
	_tree_config = EnvironmentConfig.new(
		0.15,  # density
		"res://resources/entity/environment/trees/Tree.tscn",
		3,     # min_spacing
		1      # layer_priority: 1 = environment_layer_2 (collision)
	)
	_tree_config.position_variance = 0
	_tree_config.rotation_variance = 0
	
	# Grass goes to layer 1 (no collision layer)
	_grass_config = EnvironmentConfig.new(
		0.8,   # density
		"res://resources/entity/environment/grass/Grass.tscn",
		1,     # min_spacing
		0      # layer_priority: 0 = environment_layer_1 (no collision)
	)
	_grass_config.position_variance = 0
	_grass_config.rotation_variance = 0
	
	Logger.log(self, "[CONFIG] Configurations set | Trees: layer_2 (collision), density=" + str(_tree_config.density) + " | Grass: layer_1 (no collision), density=" + str(_grass_config.density))

func _initialize_placement_strategy() -> void:
	var seed_to_use = generation_seed if use_fixed_seed else -1
	_placement_strategy = PlacementStrategy.new(seed_to_use)
	
	if use_fixed_seed:
		Logger.log(self, "[STRATEGY] Placement strategy initialized with fixed seed: " + str(generation_seed))
	else:
		Logger.log(self, "[STRATEGY] Placement strategy initialized with random seed")

func _validate_environment_layers() -> bool:
	var valid = true
	
	if not environment_layer_1:
		Logger.log(self, "[VALIDATION_ERROR] environment_layer_1 is null - grass objects cannot be placed!")
		valid = false
	else:
		Logger.log(self, "[VALIDATION_OK] environment_layer_1 found: " + environment_layer_1.name)
	
	if not environment_layer_2:
		Logger.log(self, "[VALIDATION_ERROR] environment_layer_2 is null - tree objects cannot be placed!")
		valid = false
	else:
		Logger.log(self, "[VALIDATION_OK] environment_layer_2 found: " + environment_layer_2.name)
	
	return valid

func draw_lower_environment(current_chunk_type: Outside_Constants.LOWER_CHUNK, current_chunk_index: int) -> void:
	Logger.log(self, "[ENVIRONMENT_DRAW] Starting environment draw for chunk type: " + str(current_chunk_type) + ", index: " + str(current_chunk_index))
	
	if not _validate_environment_layers():
		Logger.log(self, "[DRAW_ERROR] Cannot draw environment - layers not properly configured")
		return
	
	var start_y: int = Outside_Constants.UPPER_CHUNK_TILE_HEIGHT - Outside_Constants.TILE_SIZE
	var start_x: int = current_chunk_index * Outside_Constants.CHUNK_TILE_WIDTH
	
	match current_chunk_type:
		Outside_Constants.LOWER_CHUNK.GRASS:
			_draw_grass_chunk(start_x, start_y)
		Outside_Constants.LOWER_CHUNK.ROAD:
			_draw_road_chunk(start_x, start_y)
		Outside_Constants.LOWER_CHUNK.PARK:
			_draw_park_chunk(start_x, start_y)
		Outside_Constants.LOWER_CHUNK.CROSS_START:
			_draw_cross_start_chunk(start_x, start_y)
		Outside_Constants.LOWER_CHUNK.CROSS_END:
			_draw_cross_end_chunk(start_x, start_y)
		_:
			Logger.log(self, "[DRAW_ERROR] Unknown chunk type: " + str(current_chunk_type))
	
	Logger.log(self, "[ENVIRONMENT_DRAW] Completed for chunk type: " + str(current_chunk_type))

func _draw_grass_chunk(start_x: int, start_y: int) -> void:
	Logger.log(self, "[GRASS_CHUNK] Drawing grass chunk at (" + str(start_x) + ", " + str(start_y) + ")")
	
	# Calculate areas for placement
	var tree_area_height = Outside_Constants.CHUNK_TILE_HEIGHT - Outside_Constants.LOWER_CHUNK_TILE_HEIGHT - 4
	var grass_area_height = Outside_Constants.CHUNK_TILE_HEIGHT - Outside_Constants.LOWER_CHUNK_TILE_HEIGHT
	
	# Place grass on layer 1 (no collision)
	var grass_placed = 0
	if environment_layer_1:
		grass_placed = _placement_strategy.place_objects_in_area(
			start_x,
			start_y + Outside_Constants.LOWER_CHUNK_TILE_HEIGHT,
			Outside_Constants.CHUNK_TILE_WIDTH,
			grass_area_height,
			_grass_config,
			environment_layer_1  # Use layer 1 for grass
		)
	else:
		Logger.log(self, "[GRASS_CHUNK_WARNING] Cannot place grass - environment_layer_1 is null")
	
	# Place trees on layer 2 (collision/interaction)
	var trees_placed = 0
	if environment_layer_2:
		trees_placed = _placement_strategy.place_objects_in_area(
			start_x,
			start_y + Outside_Constants.LOWER_CHUNK_TILE_HEIGHT,
			Outside_Constants.CHUNK_TILE_WIDTH,
			tree_area_height,
			_tree_config,
			environment_layer_2  # Use layer 2 for trees
		)
	else:
		Logger.log(self, "[GRASS_CHUNK_WARNING] Cannot place trees - environment_layer_2 is null")
	
	Logger.log(self, "[GRASS_CHUNK_COMPLETE] Grass: " + str(grass_placed) + " on layer_1 | Trees: " + str(trees_placed) + " on layer_2")

func _draw_road_chunk(start_x: int, start_y: int) -> void:
	Logger.log(self, "[ROAD_CHUNK] Drawing road chunk at (" + str(start_x) + ", " + str(start_y) + ")")
	# Road chunks typically have no environment objects, but you can add street lights, signs, etc.
	# Example: Place street lights on layer 2 (collision)
	pass

func _draw_park_chunk(start_x: int, start_y: int) -> void:
	Logger.log(self, "[PARK_CHUNK] Drawing park chunk at (" + str(start_x) + ", " + str(start_y) + ")")
	
	# Parks have more dense vegetation
	var park_tree_config = _tree_config  # Use existing tree config
	var park_grass_config = _grass_config  # Use existing grass config
	
	# Temporarily increase density for park
	var original_tree_density = park_tree_config.density
	var original_grass_density = park_grass_config.density
	park_tree_config.density = min(0.25, original_tree_density * 1.5)
	park_grass_config.density = min(0.95, original_grass_density * 1.2)
	
	var area_height = Outside_Constants.CHUNK_TILE_HEIGHT - Outside_Constants.LOWER_CHUNK_TILE_HEIGHT
	
	# Place dense grass on layer 1
	if environment_layer_1:
		_placement_strategy.place_objects_in_area(
			start_x,
			start_y + Outside_Constants.LOWER_CHUNK_TILE_HEIGHT,
			Outside_Constants.CHUNK_TILE_WIDTH,
			area_height,
			park_grass_config,
			environment_layer_1
		)
	
	# Place more trees on layer 2
	if environment_layer_2:
		_placement_strategy.place_objects_in_area(
			start_x,
			start_y + Outside_Constants.LOWER_CHUNK_TILE_HEIGHT,
			Outside_Constants.CHUNK_TILE_WIDTH,
			area_height - 2,  # Leave some space at bottom
			park_tree_config,
			environment_layer_2
		)
	
	# Restore original densities
	park_tree_config.density = original_tree_density
	park_grass_config.density = original_grass_density
	
	Logger.log(self, "[PARK_CHUNK_COMPLETE] Park environment placed with increased density")

func _draw_cross_start_chunk(start_x: int, start_y: int) -> void:
	Logger.log(self, "[CROSS_START_CHUNK] Drawing cross start at (" + str(start_x) + ", " + str(start_y) + ")")
	# Minimal environment for crossing areas
	pass

func _draw_cross_end_chunk(start_x: int, start_y: int) -> void:
	Logger.log(self, "[CROSS_END_CHUNK] Drawing cross end at (" + str(start_x) + ", " + str(start_y) + ")")
	# Minimal environment for crossing areas
	pass

## Utility methods for runtime configuration
func set_tree_density(density: float) -> void:
	var old_density = _tree_config.density
	_tree_config.density = clamp(density, 0.0, 1.0)
	Logger.log(self, "[CONFIG_UPDATE] Tree density changed: " + str(old_density) + " -> " + str(_tree_config.density))

func set_grass_density(density: float) -> void:
	var old_density = _grass_config.density
	_grass_config.density = clamp(density, 0.0, 1.0)
	Logger.log(self, "[CONFIG_UPDATE] Grass density changed: " + str(old_density) + " -> " + str(_grass_config.density))

func add_custom_environment_object(scene_path: String, density: float, use_collision: bool, min_spacing: int = 1) -> EnvironmentConfig:
	var layer = 1 if use_collision else 0  # Layer 2 for collision, Layer 1 for no collision
	Logger.log(self, "[CONFIG_CREATE] New environment object | Scene: " + scene_path + " | Layer: " + str(layer) + " | Density: " + str(density))
	return EnvironmentConfig.new(density, scene_path, min_spacing, layer)
