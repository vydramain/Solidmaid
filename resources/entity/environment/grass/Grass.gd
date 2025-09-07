extends Node2D

@export var tile_size: int = 8
@export var tile_height: int = 1
@export var tile_width: int = 8

@export var sprite_type: int = 0  # 0-3 for four different sprites
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Arrays to hold your sprite textures and animation names
var sprite_textures: Array[Texture2D] = []
var animation_names: Array[String] = []

func _ready():
	# Load your sprite textures - replace with your actual texture paths
	sprite_textures = [
		preload("res://assets/textures/outside/grass_1.png"),
		preload("res://assets/textures/outside/grass_2.png"),
		preload("res://assets/textures/outside/grass_3.png"),
		preload("res://assets/textures/outside/grass_4.png")
	]
	
	# Define animation names for each sprite type
	animation_names = [
		"idle_0",
		"idle_1", 
		"idle_2",
		"idle_3"
	]
	
	setup_sprite_and_animation()

func setup_sprite_and_animation():
	# Clamp sprite_type to valid range
	sprite_type = clamp(sprite_type, 0, 3)
	
	# Set the sprite texture
	if sprite_textures[sprite_type]:
		sprite.texture = sprite_textures[sprite_type]
	
	# Play the corresponding animation
	if animation_player.has_animation(animation_names[sprite_type]):
		animation_player.play(animation_names[sprite_type])

# Optional: Function to change sprite type at runtime
func set_sprite_type(new_type: int):
	sprite_type = new_type
	setup_sprite_and_animation()
