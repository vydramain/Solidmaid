extends CharacterBody2D

@onready var ANIMATION_PLAYER = $AnimationPlayer

@export var tile_size: int = 8
@export var tile_height: int = 6
@export var tile_width: int = 4

func _ready() -> void:
	ANIMATION_PLAYER.play("Wind")
