extends CharacterBody2D

@onready var ANIMATION_PLAYER = $AnimationPlayer

@export var TILE_SIZE: int = 8
@export var TILE_HEIGHT: int = 3
@export var TILE_WIDTH: int = 2

func _ready() -> void:
	ANIMATION_PLAYER.play("Wind")
