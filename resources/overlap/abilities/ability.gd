extends Node


@export_enum("None", "Melee", "Throw")
var ability_kind := 0

const ABILITY_TO_MELEE := preload("uid://dhmq6rs2bra72")
const ABILITY_TO_THROW := preload("uid://cv4exexfb86ps")

var ability_scene: PackedScene:
	get:
		match ability_kind:
			1: return ABILITY_TO_MELEE
			2: return ABILITY_TO_THROW
			_: return null

var active: bool = false


signal started
signal ended
signal failed(reason)


func _ready() -> void:
	var scene = ability_scene
	if scene == null:
		push_error("Ability kind %d has no associated scene" % ability_kind)
	else:
		Custom_Logger.debug(self, "Loaded ability scene: '%s'" % scene)


func request_start(ctx) -> void:
	if ability_scene == null:
		push_error("Cannot start ability: no scene defined")
		emit_signal("failed", "no_scene")
		return
	var ability_instance = ability_scene.instantiate()
	add_child(ability_instance)
	emit_signal("started")
	active = true
	Custom_Logger.debug(self, "Ability started with context: '%s'" % ctx)

func request_stop() -> void:
	emit_signal("ended")
	active = false
	Custom_Logger.debug(self, "Ability stopped")

func is_active() -> bool:
	return active
