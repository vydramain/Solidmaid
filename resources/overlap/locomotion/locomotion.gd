extends CharacterBody3D

@export var speed: float = 5.0
@export var acceleration: float = 0.0
@export var sensitivity: float = 0.006
@export var gravity: float = 30.0
@export var pitch_max: float = deg_to_rad(85)

var look_yaw := 0.0
var look_pitch := 0.0

@onready var camera_pivot: Node3D = $"CameraRig"

func set_camera_correction(dir: Vector2) -> Vector3:
	# Камера/пивот — ребёнок текущего тела (у тебя $CameraRig)
	var cam_basis: Basis = camera_pivot.global_transform.basis
	
	# Горизонтальные оси из камеры
	var right: Vector3 = cam_basis.x
	var forward: Vector3 = cam_basis.z   # В Godot «вперёд» — это -Z
	right.y = 0
	forward.y = 0
	right = right.normalized()
	forward = forward.normalized()
	
	# Нормализуем ввод, чтобы по диагонали не было буста скорости
	var in2 := dir
	if in2.length() > 1.0:
		in2 = in2.normalized()
	
	# Проецируем 2D-ввод на горизонтальные оси камеры
	var move_dir: Vector3 = (right * in2.x) + (forward * in2.y)
	return move_dir

func set_move_input(dir: Vector2) -> void: 
	var move_dir: Vector3 = set_camera_correction(dir)
	velocity.x = move_dir.x * speed
	velocity.z = move_dir.z * speed

func set_look_delta(delta: Vector2):
	look_yaw -= delta.x * sensitivity
	look_pitch = clamp(look_pitch - delta.y * sensitivity, -pitch_max, pitch_max)
	rotation.y = look_yaw
	camera_pivot.rotation.x = look_pitch

func set_sprint(bool) -> void:
	pass

func set_jump(bool) -> void:
	pass

func _physics_process(dt) -> void:
	if not is_on_floor(): velocity.y -= gravity * dt
	move_and_slide()
