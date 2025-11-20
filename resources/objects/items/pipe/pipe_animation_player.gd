@tool
extends AnimationPlayer
class_name PipeSwingTool

# Editor tool that procedurally rebuilds the pipe swing animation.

@export_node_path("Node3D") var animated_node_path: NodePath = NodePath("MeshRoot"):
	set(value):
		animated_node_path = value
		_queue_rebuild()

@export var animation_name: StringName = &"swing_horizontal":
	set(value):
		animation_name = value
		_queue_rebuild()

@export var reset_animation_name: StringName = &"RESET":
	set(value):
		reset_animation_name = value
		_queue_rebuild()

@export_range(0.01, 2.0, 0.01, "suffix:s") var t_windup: float = 0.10:
	set(value):
		var clamped = max(0.01, value)
		if is_equal_approx(t_windup, clamped):
			return
		t_windup = clamped
		_queue_rebuild()

@export_range(0.01, 2.0, 0.01, "suffix:s") var t_swing: float = 0.16:
	set(value):
		var clamped = max(0.01, value)
		if is_equal_approx(t_swing, clamped):
			return
		t_swing = clamped
		_queue_rebuild()

@export_range(0.01, 2.0, 0.01, "suffix:s") var t_follow: float = 0.09:
	set(value):
		var clamped = max(0.01, value)
		if is_equal_approx(t_follow, clamped):
			return
		t_follow = clamped
		_queue_rebuild()

@export_range(0.01, 2.0, 0.01, "suffix:s") var t_recovery: float = 0.08:
	set(value):
		var clamped = max(0.01, value)
		if is_equal_approx(t_recovery, clamped):
			return
		t_recovery = clamped
		_queue_rebuild()

@export_range(2, 24, 1) var windup_samples: int = 3:
	set(value):
		var clamped = clamp(value, 2, 24)
		if windup_samples == clamped:
			return
		windup_samples = clamped
		_queue_rebuild()

@export_range(3, 48, 1) var swing_samples: int = 9:
	set(value):
		var clamped = clamp(value, 3, 48)
		if swing_samples == clamped:
			return
		swing_samples = clamped
		_queue_rebuild()

@export_range(2, 24, 1) var follow_samples: int = 3:
	set(value):
		var clamped = clamp(value, 2, 24)
		if follow_samples == clamped:
			return
		follow_samples = clamped
		_queue_rebuild()

@export_range(2, 24, 1) var recovery_samples: int = 3:
	set(value):
		var clamped = clamp(value, 2, 24)
		if recovery_samples == clamped:
			return
		recovery_samples = clamped
		_queue_rebuild()

@export var start_offset: Vector3 = Vector3(0.8, -0.1, -0.2):
	set(value):
		start_offset = value
		_queue_rebuild()

@export var apex_offset: Vector3 = Vector3(0.0, -0.1, 0.4):
	set(value):
		apex_offset = value
		_queue_rebuild()

@export var end_offset: Vector3 = Vector3(-0.7, -0.1, -0.2):
	set(value):
		end_offset = value
		_queue_rebuild()

@export var follow_offset: Vector3 = Vector3(-0.85, -0.12, -0.25):
	set(value):
		follow_offset = value
		_queue_rebuild()

@export_range(-360.0, 360.0, 0.1, "suffix:deg") var yaw_start_offset_deg: float = 150.0:
	set(value):
		yaw_start_offset_deg = value
		_queue_rebuild()

@export_range(-360.0, 360.0, 0.1, "suffix:deg") var yaw_end_offset_deg: float = -150.0:
	set(value):
		yaw_end_offset_deg = value
		_queue_rebuild()

@export_range(0.5, 4.0, 0.05) var rotation_ease_power: float = 1.2:
	set(value):
		rotation_ease_power = value
		_queue_rebuild()

@export var auto_rebuild_on_ready := true

@export var rebuild_now := false:
	set(value):
		if not value:
			return
		rebuild_now = false
		_queue_rebuild()

var _queued := false


func _ready() -> void:
	if Engine.is_editor_hint() and auto_rebuild_on_ready:
		_queue_rebuild()


func _queue_rebuild() -> void:
	if not Engine.is_editor_hint():
		return
	if _queued:
		return
	_queued = true
	call_deferred("_rebuild_animation_deferred")


func _rebuild_animation_deferred() -> void:
	_queued = false
	_rebuild_animation()


func _rebuild_animation() -> void:
	var root := _get_animation_root()
	if root == null:
		push_warning("Pipe swing tool: cannot find an owner/root to resolve %s" % animated_node_path)
		return

	var target: Node3D = root.get_node_or_null(animated_node_path)
	if target == null:
		push_warning("Pipe swing tool: node %s not found under %s" % [animated_node_path, root.name])
		return

	var library := _get_or_create_library()
	var swing_animation := _get_or_create_animation(library, animation_name)
	var reset_animation := _get_or_create_animation(library, reset_animation_name)

	var swing_keys := _build_keys(target)
	_fill_swing_animation(swing_animation, swing_keys)
	_fill_reset_animation(reset_animation, swing_keys)


func _get_animation_root() -> Node:
	if get_owner():
		return get_owner()
	return get_parent()


func _get_or_create_library() -> AnimationLibrary:
	var library := get_animation_library("")
	if library == null:
		library = AnimationLibrary.new()
		add_animation_library("", library)
	return library


func _get_or_create_animation(library: AnimationLibrary, name: StringName) -> Animation:
	var animation := library.get_animation(name)
	if animation == null:
		animation = Animation.new()
		library.add_animation(name, animation)
	return animation


func _build_keys(target: Node3D) -> Array:
	var base_position := target.position
	var base_rotation := target.rotation
	var yaw_idle := base_rotation.y
	var yaw_start := yaw_idle + deg_to_rad(yaw_start_offset_deg)
	var yaw_end := yaw_idle + deg_to_rad(yaw_end_offset_deg)

	var keys: Array = []
	var t_cursor := 0.0

	# Phase 1: windup (idle -> start)
	var windup_positions := _sample_linear_phase(
		base_position,
		base_position + start_offset,
		t_windup,
		windup_samples
	)
	var windup_yaws := _sample_linear_rotation(yaw_idle, yaw_start, windup_samples)
	_append_phase_keys(keys, windup_positions, windup_yaws, t_cursor, base_rotation)
	t_cursor += t_windup

	# Phase 2: swing (start -> apex -> end)
	var swing_positions := _sample_quadratic_bezier_phase(
		base_position + start_offset,
		base_position + apex_offset,
		base_position + end_offset,
		t_swing,
		swing_samples
	)
	var swing_yaws := _sample_eased_rotation(yaw_start, yaw_end, swing_samples)
	_append_phase_keys(keys, swing_positions, swing_yaws, t_cursor, base_rotation, true)
	t_cursor += t_swing

	# Phase 3: follow-through (end -> follow)
	var follow_positions := _sample_linear_phase(
		base_position + end_offset,
		base_position + follow_offset,
		t_follow,
		follow_samples
	)
	var follow_yaws := _sample_linear_rotation(yaw_end, yaw_end, follow_samples)
	_append_phase_keys(keys, follow_positions, follow_yaws, t_cursor, base_rotation, true)
	t_cursor += t_follow

	# Phase 4: recovery (follow -> idle)
	var recovery_positions := _sample_linear_phase(
		base_position + follow_offset,
		base_position,
		t_recovery,
		recovery_samples
	)
	var recovery_yaws := _sample_linear_rotation(yaw_end, yaw_idle, recovery_samples)
	_append_phase_keys(keys, recovery_positions, recovery_yaws, t_cursor, base_rotation, true)

	return keys


func _fill_swing_animation(animation: Animation, keys: Array) -> void:
	_clear_tracks(animation)
	animation.length = _total_duration()
	animation.loop_mode = Animation.LOOP_NONE

	var rotation_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(rotation_track, NodePath("%s:rotation" % animated_node_path))
	animation.track_set_interpolation_type(rotation_track, Animation.INTERPOLATION_CUBIC)
	animation.value_track_set_update_mode(rotation_track, Animation.UPDATE_CONTINUOUS)

	var position_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(position_track, NodePath("%s:position" % animated_node_path))
	animation.track_set_interpolation_type(position_track, Animation.INTERPOLATION_CUBIC)
	animation.value_track_set_update_mode(position_track, Animation.UPDATE_CONTINUOUS)

	for key in keys:
		animation.track_insert_key(rotation_track, key.time, key.rotation)
		animation.track_insert_key(position_track, key.time, key.position)


func _fill_reset_animation(animation: Animation, keys: Array) -> void:
	_clear_tracks(animation)
	animation.length = 0.001
	var first_key: Dictionary = keys[0]

	var rotation_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(rotation_track, NodePath("%s:rotation" % animated_node_path))
	animation.track_insert_key(rotation_track, 0.0, first_key.rotation)

	var position_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(position_track, NodePath("%s:position" % animated_node_path))
	animation.track_insert_key(position_track, 0.0, first_key.position)


func _clear_tracks(animation: Animation) -> void:
	for track_index in range(animation.get_track_count() - 1, -1, -1):
		animation.remove_track(track_index)


func _quadratic_bezier(a: Vector3, b: Vector3, c: Vector3, t: float) -> Vector3:
	var omt := 1.0 - t
	return omt * omt * a + 2.0 * omt * t * b + t * t * c


func _total_duration() -> float:
	return t_windup + t_swing + t_follow + t_recovery


func _sample_linear_phase(a: Vector3, b: Vector3, duration: float, count: int) -> Array:
	var samples_count = max(2, count)
	var result: Array = []
	for i in range(samples_count):
		var t := float(i) / float(samples_count - 1)
		result.append({
			"time": t * duration,
			"position": a.lerp(b, t),
		})
	return result


func _sample_quadratic_bezier_phase(a: Vector3, b: Vector3, c: Vector3, duration: float, count: int) -> Array:
	var samples_count = max(3, count)
	var result: Array = []
	for i in range(samples_count):
		var t := float(i) / float(samples_count - 1)
		result.append({
			"time": t * duration,
			"position": _quadratic_bezier(a, b, c, t),
		})
	return result


func _sample_linear_rotation(a: float, b: float, count: int) -> Array:
	var samples_count = max(2, count)
	var result: Array = []
	for i in range(samples_count):
		var t := float(i) / float(samples_count - 1)
		result.append(lerp_angle(a, b, t))
	return result


func _sample_eased_rotation(a: float, b: float, count: int) -> Array:
	var samples_count = max(3, count)
	var result: Array = []
	for i in range(samples_count):
		var t := float(i) / float(samples_count - 1)
		var eased := pow(t, rotation_ease_power)
		result.append(lerp_angle(a, b, eased))
	return result


func _append_phase_keys(keys: Array, positions: Array, yaws: Array, start_time: float, base_rotation: Vector3, skip_first := false) -> void:
	var first_index := 0 if not skip_first else 1
	for i in range(first_index, positions.size()):
		var pos_key: Dictionary = positions[i]
		var yaw = yaws[min(i, yaws.size() - 1)]
		keys.append({
			"time": start_time + pos_key.time,
			"position": pos_key.position,
			"rotation": Vector3(base_rotation.x, yaw, base_rotation.z),
		})
