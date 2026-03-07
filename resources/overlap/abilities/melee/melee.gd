extends Node
class_name MeleeAbility

# PATTERN: Component
# This node should remain the melee-specific gameplay component attached to the actor.
# Keep cooldowns, attack validation, and melee flow orchestration here.
#
# PATTERN: Mediator / Orchestrator
# This ability should coordinate other systems instead of owning their details:
# - ask the weapon's melee affordance for data
# - ask the character presentation layer to play visuals
# - ask hitbox logic to open/close attack windows
# - react to hit events and then trigger feedback
#
# PATTERN: Strategy + Data-Driven Design
# The concrete melee style should come from the held item's affordance/profile,
# not from hardcoded assumptions inside this ability. Pipe, knife, fist, etc.
# should provide different data while this ability stays generic.
#
# REFACTOR PLAN
# 1. Replace direct hand/weapon animation branching with one presentation entry point,
#    e.g. "play_melee_presentation(character, weapon, slot_name, melee_profile)".
# 2. Let that entry point decide whether hands are the primary driver and the weapon
#    is secondary, or whether a weapon-specific override is needed.
# 3. Move hit timing data out of this file into melee affordance/profile data so the
#    attack window is configured per weapon and not hardcoded per ability.
# 4. Move hitstop/camera shake to the actual hit-confirm path when hitbox logic exists,
#    leaving startup-only feedback here only as a temporary fallback.

@export_range(0.1, 2.0, 0.05, "suffix:s") var cooldown_seconds: float = 0.4
@export var default_animation: StringName = &"swing_horizontal"

var _cooldown_left := 0.0


func perform_melee(character, weapon: Node, slot_name: StringName) -> bool:
	# PATTERN: Command gate
	# This method is the "try execute melee attack" command handler.
	# It should answer three questions in order:
	# 1. Can the attack start?
	# 2. Which presentation/data profile should drive the attack?
	# 3. Which downstream systems must be notified?
	if weapon == null or _cooldown_left > 0.0:
		return false
	
	# PATTERN: Presentation orchestration
	# TODO: collapse these separate calls behind a single melee presentation contract.
	# The ability should still orchestrate, but not manually know every visual layer.
	# A future presentation method can internally decide:
	# - play hand animation
	# - play weapon animation
	# - schedule hitbox window markers
	# - emit animation lifecycle events
	var played_anim := play_hand_animation(character, weapon, slot_name)
	play_weapon_animation(weapon)
	
	# PATTERN: Observer / Event-Driven
	# TODO: when hitboxes are wired, move this from "attack started" toward
	# "attack connected" so feedback reflects impact instead of button press.
	trigger_melee_feedback(character, slot_name, weapon)
	_cooldown_left = cooldown_seconds
	set_process(true)
	return true


func play_weapon_animation(weapon: Node) -> bool:
	# PATTERN: Secondary presentation layer
	# Keep this as a thin adapter only if weapon-local motion remains useful.
	# If hands become the single primary animation source, this method can either:
	# - become optional flavor motion, or
	# - be folded into a dedicated melee presentation service.
	var animation_player: AnimationPlayer = weapon.get_node_or_null("AnimationPlayer")
	if animation_player and animation_player.has_animation(default_animation):
		animation_player.play(default_animation)
		return true
	return false


func trigger_melee_feedback(character, slot_name: StringName, weapon: Node) -> void:
	# PATTERN: Feedback system boundary
	# This method should stay about "feel" only: shake, hitstop, sound, screenshake.
	# It should not decide damage, affordance lookup, or animation selection.
	# Long-term, prefer calling it from hit-confirm or attack-phase events.
	if character == null:
		return
	if character.has_method("trigger_camera_shake"):
		character.trigger_camera_shake(0.25, 0.09)
	if character.has_method("trigger_hitstop"):
		character.trigger_hitstop(0.05, 0.35)


func play_hand_animation(character, weapon: Node, slot_name: StringName) -> bool:
	# PATTERN: Strategy lookup
	# The ability asks the held item which hand animation profile to use.
	# Keep this lookup generic so different melee-capable items can swap behavior
	# without forking the ability implementation.
	if character == null:
		return false
	
	var profile := get_hand_profile(weapon)
	if profile == null:
		return false
	
	var anim_name := profile.get_animation(&"melee", "fp")
	if anim_name == StringName():
		return false
	
	if character.has_method("play_hand_animation"):
		return character.play_hand_animation(anim_name, slot_name, "fp")
	
	return false


func get_hand_profile(weapon: Node) -> HandAnimationProfile:
	# PATTERN: Data-Driven Design
	# This is the current seam where hardcoded melee behavior can be replaced by data.
	# Expand this later into a richer melee profile/resource:
	# - hand animation names
	# - weapon animation names
	# - attack phase timings
	# - hitbox spawn markers
	# - impact feedback presets
	if weapon == null:
		return null
	if weapon.has_method("get_hand_animation_profile"):
		return weapon.get_hand_animation_profile()
	var aff_root := weapon.get_node_or_null("Affordances")
	if aff_root:
		for child in aff_root.get_children():
			if child.has_method("get_hand_animation_profile"):
				var profile = child.get_hand_animation_profile()
				if profile:
					return profile
	return null


func _process(delta: float) -> void:
	if _cooldown_left <= 0.0:
		set_process(false)
		return
	_cooldown_left = max(0.0, _cooldown_left - delta)
