extends Node
class_name Affordance

## Passive property stub that tags an object with an affordance name, e.g. "carriable".

@export var affordance_name: StringName
@export var enabled: bool = true


func provides(name: StringName) -> bool:
	return enabled and name == affordance_name
