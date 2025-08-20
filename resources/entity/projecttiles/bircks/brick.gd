extends "res://resources/entity/projecttiles/Projecttile.gd"

@onready var SPRITE2D = $Sprite2D

var ROTATION_SPEED = 10 

func _ready() -> void:
	SPEED = 200

func _process(delta: float) -> void:
	SPRITE2D.rotation_degrees += 90 * delta * ROTATION_SPEED
