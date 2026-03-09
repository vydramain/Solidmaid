extends Resource
class_name MeleeAttackProfile

const DEFAULT_ACTION_NAME := &"melee"

@export var action_name: StringName = DEFAULT_ACTION_NAME
@export var hand_animation_profile: HandAnimationProfile
@export var weapon_animation_name: StringName = &"melee_attack_horizontal"

@export_range(0.0, 3.0, 0.01, "suffix:s") var windup_seconds: float = 0.1
@export_range(0.01, 3.0, 0.01, "suffix:s") var active_seconds: float = 0.16
@export_range(0.0, 3.0, 0.01, "suffix:s") var recovery_seconds: float = 0.14
@export_range(0.01, 5.0, 0.01, "suffix:s") var cooldown_seconds: float = 0.4

@export var hitbox_shape: Shape3D
@export var hitbox_offset: Vector3 = Vector3(0.0, 0.0, -0.8)
@export var hitbox_rotation_degrees: Vector3 = Vector3.ZERO
@export var hitbox_scale: Vector3 = Vector3.ONE

@export_range(0, 9999, 1, "suffix:hp") var damage: int = 10

@export var impulse: float = 0.0
@export var hit_group: StringName = &"default"
@export var one_hit_only: bool = true
@export var startup_shake_strength: float = 0.0

@export_range(0.0, 1.0, 0.01, "suffix:s") var startup_shake_duration: float = 0.0
@export_range(0.0, 1.0, 0.01, "suffix:s") var startup_hitstop_duration: float = 0.0
@export_range(0.0, 1.0, 0.01) var startup_hitstop_scale: float = 0.35

@export var impact_shake_strength: float = 0.25

@export_range(0.0, 1.0, 0.01, "suffix:s") var impact_shake_duration: float = 0.09
@export_range(0.0, 1.0, 0.01, "suffix:s") var impact_hitstop_duration: float = 0.05
@export_range(0.0, 1.0, 0.01) var impact_hitstop_scale: float = 0.35


func get_hand_animation(perspective: String = "fp") -> StringName:
	if hand_animation_profile == null:
		return StringName()
	return hand_animation_profile.get_animation(action_name, perspective)


func get_total_duration() -> float:
	return windup_seconds + active_seconds + recovery_seconds
