extends Affordance
class_name CarriableAffordance

const NAME_CARRIABLE := &"carriable"

@export var carriable: bool = true


func _ready() -> void:
	affordance_name = NAME_CARRIABLE


func provides(provided_name: StringName) -> bool:
	if not carriable:
		return false
	return super.provides(provided_name)
