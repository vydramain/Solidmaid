extends Node
class_name Affordance

## Passive property stub that tags an object with an affordance name, e.g. "carriable".
##
## PATTERN: Capability descriptor
## Base Affordance nodes model how an object may be used by some ability.
## They should answer "what kind of target/item is this for interaction purposes?".
##
## ARCHITECTURE RULE
## Affordance supplies compatibility and per-item data.
## Ability supplies actor intent and action orchestration.

@export var affordance_name: StringName
@export var enabled: bool = true


func provides(name: StringName) -> bool:
	return enabled and name == affordance_name
