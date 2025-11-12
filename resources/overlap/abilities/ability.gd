extends Node


@export_enum("None", "Melee", "Throw")
var ability_kind := 0

const ABILITY_TO_MELEE := preload("uid://dhmq6rs2bra72")
const ABILITY_TO_THROW := preload("uid://cv4exexfb86ps")

@export var dependency_scenes: Array[PackedScene] = []

var ability_scene: PackedScene:
	get:
		match ability_kind:
			1: return ABILITY_TO_MELEE
			2: return ABILITY_TO_THROW
			_: return null

var active: bool = false
var _dependencies_instantiated := false


signal started
signal ended
signal failed(reason)


func _enter_tree() -> void:
	_instantiate_dependencies()


func _ready() -> void:
	_instantiate_dependencies()
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


func _instantiate_dependencies() -> void:
	if _dependencies_instantiated:
		return

	var target_parent: Node = _find_dependency_host()
	if target_parent == null:
		target_parent = self

	for dependency_scene in dependency_scenes:
		if dependency_scene == null:
			continue
		var dependency_instance = dependency_scene.instantiate()
		if target_parent.is_node_ready():
			_add_child_and_register(target_parent, dependency_instance)
		else:
			call_deferred("_ability_add_dependency_child", dependency_instance)
			call_deferred("_ability_register_dependency_deferred", dependency_instance)

	_dependencies_instantiated = true


func _find_dependency_host() -> Node:
	var node: Node = self
	while node:
		if node.has_method("register_ability_dependency"):
			return node
		node = node.get_parent()
	return get_owner()


func _ability_add_dependency_child(dependency_instance: Node) -> void:
	var target_parent: Node = _find_dependency_host()
	if target_parent == null:
		target_parent = self
	if dependency_instance.get_parent() == target_parent:
		return
	if dependency_instance.get_parent():
		dependency_instance.get_parent().remove_child(dependency_instance)
	target_parent.add_child(dependency_instance)


func _ability_register_dependency_deferred(dependency_instance: Node) -> void:
	var host := _find_dependency_host()
	if host and host.has_method("register_ability_dependency"):
		host.register_ability_dependency(dependency_instance)


func _add_child_and_register(parent: Node, dependency_instance: Node) -> void:
	parent.add_child(dependency_instance)
	if parent.has_method("register_ability_dependency"):
		parent.register_ability_dependency(dependency_instance)
