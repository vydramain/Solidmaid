extends Affordance
class_name ThrowableAffordance

const NAME_THROWABLE := &"throwable"

@export var throwable: bool = true


func _ready() -> void:
	affordance_name = NAME_THROWABLE


func provides(name: StringName) -> bool:
	if not throwable:
		return false
	return super.provides(name)
