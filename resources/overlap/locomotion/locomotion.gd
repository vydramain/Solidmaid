extends CharacterBody3D
class_name Locomotion

@export var speed: float = 5.0
@export var acceleration: float = 12.0
@export var deceleration: float = 16.0
@export var sensitivity: float = 0.006
@export var gravity: float = 30.0
@export var pitch_max: float = deg_to_rad(85)
@export var look_pivot_path: NodePath = NodePath()

var look_yaw := 0.0
var look_pitch := 0.0
var look_pivot: Node3D
var _move_input := Vector2.ZERO


func _ready():
	refresh_look_pivot()

func _physics_process(dt) -> void:
	var desired_horizontal_velocity := get_desired_horizontal_velocity()
	var current_horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
	var accel_rate := acceleration if desired_horizontal_velocity.length() > current_horizontal_velocity.length() else deceleration
	current_horizontal_velocity = current_horizontal_velocity.move_toward(desired_horizontal_velocity, accel_rate * dt)
	velocity.x = current_horizontal_velocity.x
	velocity.z = current_horizontal_velocity.z
	if not is_on_floor(): velocity.y -= gravity * dt
	move_and_slide()


func set_camera_correction(dir: Vector2) -> Vector3:
	var pivot := look_pivot if look_pivot else self
	var cam_basis: Basis = pivot.global_transform.basis
	
	var right: Vector3 = cam_basis.x
	var forward: Vector3 = cam_basis.z   # В Godot «вперёд» — это -Z
	right.y = 0
	forward.y = 0
	right = right.normalized()
	forward = forward.normalized()
	
	var in2 := dir
	if in2.length() > 1.0:
		in2 = in2.normalized()
	
	var move_dir: Vector3 = (right * in2.x) + (forward * in2.y)
	return move_dir


func set_move_input(dir: Vector2) -> void: 
	_move_input = dir


func set_look_delta(delta: Vector2):
	var pivot := look_pivot if look_pivot else self
	look_yaw -= delta.x * sensitivity
	look_pitch = clamp(look_pitch - delta.y * sensitivity, -pitch_max, pitch_max)
	rotation.y = look_yaw
	pivot.rotation.x = look_pitch


func set_sprint(bool) -> void:
	pass


func set_jump(bool) -> void:
	pass

func refresh_look_pivot():
	if look_pivot_path.is_empty():
		look_pivot = self
		return

	var target := get_node_or_null(look_pivot_path)
	if target and target is Node3D:
		look_pivot = target
	else:
		look_pivot = self

func set_look_pivot_node(node: Node3D):
	look_pivot = node if node else self

func get_look_pivot() -> Node3D:
	return look_pivot


func get_desired_horizontal_velocity() -> Vector3:
	var move_dir := set_camera_correction(_move_input)
	move_dir.y = 0
	return move_dir * speed
