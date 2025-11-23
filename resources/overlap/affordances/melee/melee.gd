extends Affordance
class_name MeleeAffordance

const NAME_MELEE := &"melee"

@export var hand_animation_profile: HandAnimationProfile


func _ready() -> void:
	affordance_name = NAME_MELEE


func get_hand_animation_profile() -> HandAnimationProfile:
	return hand_animation_profile
