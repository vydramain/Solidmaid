extends Area2D
class_name Brick

@onready var physic_box = $PhysicBox

func _physics_process(delta: float) -> void:
	if physic_box == null:
		pass
	
	physic_box.position = Vector2.ZERO
	global_position += physic_box.linear_velocity * delta

func setup_floor_physic_line(flr: Physic_Line) -> void:
	collision_mask = 1 << flr.line_id
