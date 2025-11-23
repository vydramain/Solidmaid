extends Node3D
class_name VisionRig

@export var walk_bob_position_amplitude: Vector3 = Vector3(0.004, 0.012, 0.002)
@export var walk_bob_rotation_degrees: Vector3 = Vector3(0.65, 0.0, 0.25)

@export_range(0.1, 20.0, 0.1, "suffix:hz") var walk_bob_frequency_hz: float = 5.8
@export_range(0.5, 10.0, 0.1, "suffix:m/s") var walk_bob_reference_speed: float = 5.0
@export_range(1.0, 20.0, 0.5) var walk_bob_smoothing: float = 10.0

@export_range(0.0, 0.2, 0.005, "suffix:m") var default_pos_amplitude: float = 0.025
@export_range(0.0, 4.0, 0.1, "suffix:deg") var default_rot_amplitude_deg: float = 1.5
@export_range(0.01, 0.5, 0.01, "suffix:s") var default_duration: float = 0.12


var _camera: Camera3D
var _base_camera_transform: Transform3D
var _rng := RandomNumberGenerator.new()
var _shake_time_left := 0.0
var _shake_duration := 0.0
var _shake_strength := 0.0
var _walk_phase := 0.0
var _walk_amount := 0.0
var _host_locomotion: Locomotion


func _ready() -> void:
	_rng.randomize()
	_camera = get_node_or_null("LookPivot/Camera3D")
	if _camera:
		_base_camera_transform = _camera.transform
	_host_locomotion = get_parent() if get_parent() is Locomotion else null
	set_process(true)


func _process(delta: float) -> void:
	if not _camera:
		return
	_update_walk_bob(delta)
	var final_transform := _base_camera_transform
	final_transform = _apply_walk_bob(final_transform)
	if _shake_time_left > 0.0:
		_shake_time_left = max(0.0, _shake_time_left - delta)
		var time_ratio := 0.0
		if _shake_duration > 0.0:
			time_ratio = 1.0 - (_shake_time_left / _shake_duration)
		var damping := 1.0 - time_ratio
		final_transform = _apply_micro_shake(final_transform, damping)
	else:
		_shake_strength = 0.0
	_camera.transform = final_transform


func trigger_micro_shake(strength: float = 1.0, duration: float = -1.0) -> void:
	if duration <= 0.0:
		duration = default_duration
	_shake_duration = duration
	_shake_time_left = duration
	_shake_strength = max(strength, _shake_strength)


func _update_walk_bob(delta: float) -> void:
	if _host_locomotion == null and get_parent() is Locomotion:
		_host_locomotion = get_parent()
	if _host_locomotion == null:
		_walk_amount = 0.0
		return
	var horizontal_speed := Vector2(_host_locomotion.velocity.x, _host_locomotion.velocity.z).length()
	var target_amount := clampf(horizontal_speed / walk_bob_reference_speed, 0.0, 1.0)
	_walk_amount = lerp(_walk_amount, target_amount, delta * walk_bob_smoothing)
	if _walk_amount > 0.001:
		_walk_phase = fmod(_walk_phase + delta * walk_bob_frequency_hz * TAU, TAU)


func _apply_walk_bob(base_transform: Transform3D) -> Transform3D:
	if _walk_amount <= 0.001:
		return base_transform
	var sin_wave := sin(_walk_phase)
	var sin_wave_abs := absf(sin(_walk_phase * 2))
	var offset := Vector3(
		walk_bob_position_amplitude.x * sin_wave,
		walk_bob_position_amplitude.y * sin_wave_abs,
		walk_bob_position_amplitude.z * -sin_wave
	) * _walk_amount
	var rot_offset := Vector3(
		deg_to_rad(walk_bob_rotation_degrees.x) * sin_wave_abs,
		.0,
		deg_to_rad(walk_bob_rotation_degrees.z) * -sin_wave
	) * _walk_amount
	var transformed := base_transform
	transformed.origin += offset
	var trans_basis := transformed.basis
	trans_basis = trans_basis.rotated(Vector3.RIGHT, rot_offset.x)
	trans_basis = trans_basis.rotated(Vector3.UP, rot_offset.y)
	trans_basis = trans_basis.rotated(Vector3.FORWARD, rot_offset.z)
	transformed.basis = trans_basis
	return transformed


func _apply_micro_shake(base_transform: Transform3D, damping: float) -> Transform3D:
	var pos_amp := default_pos_amplitude * _shake_strength * damping
	var rot_amp := deg_to_rad(default_rot_amplitude_deg) * _shake_strength * damping
	var offset := Vector3(
		_rng.randf_range(-pos_amp, pos_amp),
		_rng.randf_range(-pos_amp, pos_amp),
		_rng.randf_range(-pos_amp, pos_amp)
	)
	var rot_offset := Vector3(
		_rng.randf_range(-rot_amp, rot_amp),
		_rng.randf_range(-rot_amp, rot_amp),
		_rng.randf_range(-rot_amp, rot_amp)
	)
	var shaken := base_transform
	shaken.origin += offset
	var trans_basis := shaken.basis
	trans_basis = trans_basis.rotated(Vector3.RIGHT, rot_offset.x)
	trans_basis = trans_basis.rotated(Vector3.UP, rot_offset.y)
	trans_basis = trans_basis.rotated(Vector3.FORWARD, rot_offset.z)
	shaken.basis = trans_basis
	return shaken
