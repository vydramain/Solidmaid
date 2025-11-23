extends Node
class_name HandAnimator

@export_node_path("AnimationPlayer") var animation_player_fp_path: NodePath
@export_node_path("AnimationPlayer") var animation_player_tp_path: NodePath
@export var default_perspective: String = "fp"


func play(action_name: StringName, perspective: String = "", speed: float = 1.0) -> bool:
	var target := get_player(perspective)
	if target == null:
		push_warning("HandAnimator: missing AnimationPlayer for perspective '%s'" % perspective)
		return false
	if not target.has_animation(action_name):
		push_warning("HandAnimator: animation '%s' not found on %s" % [action_name, target.name])
		return false
	target.play(action_name, -1.0, speed, true)
	return true


func get_player(perspective: String) -> AnimationPlayer:
	var chosen := perspective if perspective != "" else default_perspective
	var path := animation_player_fp_path if chosen == "fp" else animation_player_tp_path
	if path == NodePath(""):
		return null
	return get_node_or_null(path) as AnimationPlayer
