extends CharacterBody3D

@export var speed: float = 5.0
@export var acceleration: float = 0.0
@export var sensitivity: float = 0.003
@export var gravity: float = 30.0
@export var pitch_max: float = deg_to_rad(85)

var look_yaw := 0.0
var look_pitch := 0.0

@onready var camera_pivot := $"CameraRig"

func set_move_input(dir: Vector2): 
	velocity.x = dir.x * speed
	velocity.z = dir.y * speed

func set_look_delta(delta: Vector2):
	look_yaw -= delta.x * sensitivity
	look_pitch = clamp(look_pitch - delta.y * sensitivity, -pitch_max, pitch_max)
	rotation.y = look_yaw
	camera_pivot.rotation.x = look_pitch

func set_sprint(bool) -> void:
	pass

func set_jump(bool) -> void:
	pass

func _physics_process(dt):
	if not is_on_floor(): velocity.y -= gravity * dt
	move_and_slide()
