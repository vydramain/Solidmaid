extends Node

@export var ability_name: StringName
@export var ability_aliases: Array[StringName] = []
@export var ability_scene: PackedScene
@export var dependency_scenes: Array[PackedScene] = []
@export var required_node_names: Array[StringName] = []

var active: bool = false
var _dependencies_instantiated := false
var _requirements_met := true


signal started
signal ended
signal failed(reason)


func _enter_tree() -> void:
	instantiate_dependencies()


func _ready() -> void:
	instantiate_dependencies()
	_requirements_met = verify_required_nodes()
	if ability_name == StringName():
		ability_name = StringName(name)
	if ability_scene == null:
		if dependency_scenes.is_empty():
			push_error("Ability '%s' has no associated scene" % ability_name)
		else:
			Custom_Logger.debug(self, "Ability '%s' configured via dependencies only" % ability_name)
	else:
		Custom_Logger.debug(self, "Loaded ability scene: '%s'" % ability_scene)


func request_start(ctx) -> void:
	if not _requirements_met:
		_requirements_met = verify_required_nodes()
	if not _requirements_met:
		Custom_Logger.warning(self, "Ability '%s' cannot start: missing required nodes" % ability_name)
		emit_signal("failed", "missing_requirements")
		return
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


func provides(input_name: StringName) -> bool:
	if input_name == StringName():
		return false
	if ability_name != StringName() and ability_name == input_name:
		return true
	for alias in ability_aliases:
		if alias == input_name:
			return true
	return false


func instantiate_dependencies() -> void:
	if _dependencies_instantiated:
		return

	var target_parent: Node = find_dependency_host()
	if target_parent == null:
		target_parent = self

	for dependency_scene in dependency_scenes:
		if dependency_scene == null:
			continue
		var dependency_instance = dependency_scene.instantiate()
		if target_parent.is_node_ready():
			add_child_and_register(target_parent, dependency_instance)
		else:
			call_deferred("ability_add_dependency_child", dependency_instance)
			call_deferred("ability_register_dependency_deferred", dependency_instance)

	_dependencies_instantiated = true


func verify_required_nodes() -> bool:
	if required_node_names.is_empty():
		return true
	var host := find_dependency_host()
	var search_root: Node = host if host else get_owner()
	if search_root == null:
		search_root = self
	var missing := []
	for node_name in required_node_names:
		if node_name == StringName():
			continue
		if not node_with_name_exists(search_root, node_name):
			missing.append(node_name)
	if missing.is_empty():
		return true
	var missing_names := PackedStringArray()
	for missing_name in missing:
		missing_names.append(String(missing_name))
	Custom_Logger.warning(self, "Ability '%s' disabled: missing required nodes [%s]" % [ability_name, ", ".join(missing_names)])
	return false


func find_dependency_host() -> Node:
	var node: Node = self
	while node:
		if node.has_method("register_ability_dependency"):
			return node
		node = node.get_parent()
	return get_owner()


func ability_add_dependency_child(dependency_instance: Node) -> void:
	var target_parent: Node = find_dependency_host()
	if target_parent == null:
		target_parent = self
	if dependency_instance.get_parent() == target_parent:
		return
	if dependency_instance.get_parent():
		dependency_instance.get_parent().remove_child(dependency_instance)
	target_parent.add_child(dependency_instance)


func ability_register_dependency_deferred(dependency_instance: Node) -> void:
	var host := find_dependency_host()
	if host and host.has_method("register_ability_dependency"):
		host.register_ability_dependency(dependency_instance)


func add_child_and_register(parent: Node, dependency_instance: Node) -> void:
	parent.add_child(dependency_instance)
	if parent.has_method("register_ability_dependency"):
		parent.register_ability_dependency(dependency_instance)


func node_with_name_exists(search_root: Node, node_name: StringName) -> bool:
	if search_root == null:
		return false
	if StringName(search_root.name) == node_name:
		return true
	var found := search_root.find_child(String(node_name), true, false)
	return found != null
