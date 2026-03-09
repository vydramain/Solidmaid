extends Affordance
class_name MeleeAffordance

const NAME_MELEE := &"melee"
const DEFAULT_ATTACK_ID := &"default"

# PATTERN: Affordance as capability descriptor
# This node should describe how an item may be used in melee, not execute the attack itself.
#
# PATTERN: Strategy + Data-Driven Design
# This affordance should act as a small catalog of melee variants the item supports.
# Each entry points to one MeleeAttackProfile, which describes one concrete attack.
# Examples of attack ids:
# - default
# - heavy
# - air_light
# - air_heavy
#
# REFACTOR RULE
# MeleeAbility should ask this affordance for configuration, then orchestrate the attack.
# The affordance supplies the "what kind of melee weapon is this?" answer.
# Keep this field as the default attack profile so existing scenes remain valid.
@export var melee_attack_profile: MeleeAttackProfile
@export var attack_profiles: Dictionary = {}

func _ready() -> void:
	affordance_name = NAME_MELEE


func get_melee_attack_profile(attack_id: StringName = DEFAULT_ATTACK_ID) -> MeleeAttackProfile:
	if attack_id == StringName() or attack_id == DEFAULT_ATTACK_ID:
		return melee_attack_profile
	if attack_profiles.has(attack_id):
		return attack_profiles[attack_id] as MeleeAttackProfile
	var attack_key := String(attack_id)
	if attack_profiles.has(attack_key):
		return attack_profiles[attack_key] as MeleeAttackProfile
	return melee_attack_profile
