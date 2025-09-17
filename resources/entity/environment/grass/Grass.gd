extends Node2D

@export var tile_size: int = 8
@export var tile_height: int = 1
@export var tile_width: int = 8
@export var sprite_type: int = 0  # 0-3 for four different sprites

# Use regular variables instead of @onready for dynamic instantiation
var sprite: Sprite2D
var animation_player: AnimationPlayer

# Arrays to hold your sprite textures and animation names
var sprite_textures: Array[Texture2D] = []
var animation_names: Array[String] = []

# Track initialization state
var is_initialized: bool = false

func _ready():
	# Use call_deferred to ensure the scene tree is fully set up
	call_deferred("initialize_grass")

func initialize_grass():
	# Get child nodes manually
	sprite = get_node_or_null("Sprite2D")
	animation_player = get_node_or_null("AnimationPlayer")
	
	if not validate_scene_structure():
		return
	
	load_textures()
	setup_animation_names()
	setup_sprite_and_animation()
	
	is_initialized = true
	# Only log successful initialization once per instance
	Custom_Logger.debug(self, "Grass scene initialized at position: " + str(position))

func validate_scene_structure() -> bool:
	if sprite == null:
		Custom_Logger.error(self, "Sprite2D node not found! Available children: " + str(get_children()))
		return false
	
	if animation_player == null:
		Custom_Logger.error(self, "AnimationPlayer node not found! Available children: " + str(get_children()))
		return false
	
	return true

func load_textures():
	var texture_paths = [
		"res://assets/textures/outside/grass_1.png",
		"res://assets/textures/outside/grass_2.png",
		"res://assets/textures/outside/grass_3.png",
		"res://assets/textures/outside/grass_4.png"
	]
	
	sprite_textures.clear()
	var failed_count = 0
	
	for i in range(texture_paths.size()):
		var texture = load(texture_paths[i])
		if texture == null:
			failed_count += 1
			Custom_Logger.warning(self, "Could not load texture: " + texture_paths[i])
			# Create a simple colored texture as fallback
			var fallback_texture = ImageTexture.new()
			var image = Image.create(32, 32, false, Image.FORMAT_RGB8)
			image.fill(Color.GREEN)
			fallback_texture.set_image(image)
			sprite_textures.append(fallback_texture)
		else:
			sprite_textures.append(texture)
	
	# Only log summary instead of each successful load
	if failed_count > 0:
		Custom_Logger.warning(self, "Loaded textures with " + str(failed_count) + " failures (using fallbacks)")
	else:
		Custom_Logger.debug(self, "All " + str(texture_paths.size()) + " textures loaded successfully")

func setup_animation_names():
	animation_names = [
		"idle_0",
		"idle_1", 
		"idle_2",
		"idle_3"
	]

func setup_sprite_and_animation():
	# Clamp sprite_type to valid range
	sprite_type = clamp(sprite_type, 0, sprite_textures.size() - 1)
	
	# Set the sprite texture
	if sprite_type < sprite_textures.size() and sprite_textures[sprite_type] != null:
		sprite.texture = sprite_textures[sprite_type]
		# Only log texture changes in debug mode, not every setup
		Custom_Logger.debug(self, "Set texture for sprite type: " + str(sprite_type))
	else:
		Custom_Logger.error(self, "Invalid sprite_type or texture not loaded: " + str(sprite_type))
		return
	
	# Play the corresponding animation if AnimationPlayer exists and has the animation
	if animation_player != null and sprite_type < animation_names.size():
		var anim_name = animation_names[sprite_type]
		if animation_player.has_animation(anim_name):
			animation_player.play(anim_name)
			Custom_Logger.debug(self, "Playing animation: " + anim_name)
		else:
			Custom_Logger.warning(self, "Animation not found: " + anim_name + ". Create this animation in the AnimationPlayer.")
	else:
		Custom_Logger.error(self, "Invalid sprite_type for animation: " + str(sprite_type))

# Function to change sprite type at runtime - works both before and after initialization
func set_sprite_type(new_type: int):
	if new_type >= 0 and new_type <= 3:
		# Only log if the type is actually changing
		if sprite_type != new_type:
			Custom_Logger.debug(self, "Changing sprite type from " + str(sprite_type) + " to " + str(new_type))
			sprite_type = new_type
			
			# If already initialized, update immediately
			if is_initialized and sprite != null:
				setup_sprite_and_animation()
	else:
		Custom_Logger.error(self, "Invalid sprite type: " + str(new_type) + ". Must be 0-3.")

# Optional: Function to initialize with specific type (can be called before adding to scene)
func initialize_with_type(type: int):
	# Silently clamp values - not critical enough to log
	sprite_type = clamp(type, 0, 3)
