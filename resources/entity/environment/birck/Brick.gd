extends Area2D

@onready var physic_box = $PhysicBox

func _physics_process(delta: float) -> void:
	if physic_box == null:
		pass
	
	physic_box.position = Vector2.ZERO
	global_position += physic_box.linear_velocity * delta
