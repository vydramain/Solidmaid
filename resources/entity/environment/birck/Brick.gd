extends Area2D
class_name Brick

@onready var physic_box: RigidBody2D = $PhysicBox

func _ready() -> void:
	# Make sure the rigidbody is not asleep at spawn
	physic_box.sleeping = false

func _physics_process(delta: float) -> void:
	if physic_box == null:
		pass
	
	physic_box.position = Vector2.ZERO
	global_position += physic_box.linear_velocity * delta

func launch(direction: Vector2, strength: float) -> void:
	if physic_box:
		physic_box.apply_impulse(direction.normalized() * strength)

func setup_floor_physic_line(flr: Physic_Line) -> void:
	collision_mask = 1 << flr.line_id
