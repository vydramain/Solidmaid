extends Node2D

@onready var ANIMATION_PLAYER = $AnimationPlayer

@export var TILE_SIZE: int = 8
@export var TILE_HEIGHT: int = 2
@export var TILE_WIDTH: int = 4

func _ready() -> void:
	ANIMATION_PLAYER.play("Wind")
