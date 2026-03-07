extends Affordance
class_name MeleeAffordance

const NAME_MELEE := &"melee"

# PATTERN: Affordance as capability descriptor
# This node should describe how an item may be used in melee, not execute the attack itself.
#
# PATTERN: Strategy + Data-Driven Design
# Grow this affordance/resource into the per-weapon melee strategy carrier:
# - hand animation profile
# - optional weapon animation profile/name
# - attack phase timing data
# - hitbox window timing
# - feedback preset references
# - damage / impact metadata
#
# REFACTOR RULE
# MeleeAbility should ask this affordance for configuration, then orchestrate the attack.
# The affordance supplies the "what kind of melee weapon is this?" answer.
@export var hand_animation_profile: HandAnimationProfile


func _ready() -> void:
	affordance_name = NAME_MELEE


func get_hand_animation_profile() -> HandAnimationProfile:
	return hand_animation_profile
