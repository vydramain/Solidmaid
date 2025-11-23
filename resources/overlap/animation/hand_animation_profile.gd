extends Resource
class_name HandAnimationProfile

@export var fp_anims: Dictionary = {}
@export var tp_anims: Dictionary = {}
@export var fallback_animation: StringName = StringName()


func get_animation(action: StringName, perspective: String = "fp") -> StringName:
	var lookup := fp_anims if perspective == "fp" else tp_anims
	if lookup.has(action):
		return lookup[action]
	return fallback_animation
