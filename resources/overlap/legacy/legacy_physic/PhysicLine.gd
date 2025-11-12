extends StaticBody2D
class_name Physic_Line

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var line_id: int

func _ready() -> void:
	collision_shape_2d.disabled = false

func get_line_y() -> float:
	return global_position.y
