extends Node
class_name MeleeAbility

@export_range(0.1, 2.0, 0.05, "suffix:s") var cooldown_seconds: float = 0.4
@export var default_animation: StringName = &"swing_horizontal"

var _cooldown_left := 0.0


func perform_melee(character, weapon: Node, slot_name: StringName) -> bool:
	if weapon == null:
		return false
	if _cooldown_left > 0.0:
		return false

	play_weapon_animation(weapon)

	trigger_melee_feedback(character, slot_name, weapon)
	_cooldown_left = cooldown_seconds
	set_process(true)
	return true


func play_weapon_animation(weapon: Node) -> bool:
	var animation_player: AnimationPlayer = weapon.get_node_or_null("AnimationPlayer")
	if animation_player and animation_player.has_animation(default_animation):
		animation_player.play(default_animation)
		return true
	return false


func trigger_melee_feedback(character, slot_name: StringName, weapon: Node) -> void:
	if character == null:
		return
	if character.has_method("trigger_camera_shake"):
		character.trigger_camera_shake(0.25, 0.09)
	if character.has_method("trigger_hitstop"):
		character.trigger_hitstop(0.05, 0.35)


func _process(delta: float) -> void:
	if _cooldown_left <= 0.0:
		set_process(false)
		return
	_cooldown_left = max(0.0, _cooldown_left - delta)
