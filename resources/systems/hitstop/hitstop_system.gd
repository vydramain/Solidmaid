extends Node
class_name HitstopSystem

@export_range(0.01, 0.5, 0.01, "suffix:s") var default_duration: float = 0.08
@export_range(0.0, 1.0, 0.05) var default_time_scale: float = 0.2
@export_range(0.0, 2.0, 0.1) var default_shake_strength: float = 0.4

var _active_timer := 0.0
var _original_time_scale := 1.0
var _target_rig: VisionRig

func _ready() -> void:
	set_process(false)

func trigger(duration: float = -1.0, vision_rig: VisionRig = null, time_scale_override: float = -1.0, shake_strength: float = -1.0) -> void:
	var resolved_duration := duration if duration > 0.0 else default_duration
	var resolved_time_scale := time_scale_override if time_scale_override >= 0.0 else default_time_scale
	var resolved_shake := shake_strength if shake_strength >= 0.0 else default_shake_strength

	_active_timer = resolved_duration
	_target_rig = vision_rig
	_original_time_scale = Engine.time_scale
	Engine.time_scale = resolved_time_scale
	if _target_rig:
		_target_rig.trigger_micro_shake(resolved_shake, resolved_duration)
	set_process(true)

func _process(delta: float) -> void:
	_active_timer -= delta
	if _active_timer <= 0.0:
		_end_hitstop()

func _end_hitstop() -> void:
	Engine.time_scale = _original_time_scale
	_original_time_scale = 1.0
	_target_rig = null
	set_process(false)
