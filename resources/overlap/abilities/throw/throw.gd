extends Node
class_name ThrowAbility

## Handles throw interactions routed through the ability system.


func perform_throw(character, slot_name: StringName) -> bool:
	if character == null:
		return false
	if not character.has_method("request_throw"):
		return false
	return character.request_throw(slot_name)
