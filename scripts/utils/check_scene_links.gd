extends SceneTree

const ROOT_DIR := "res://resources"

func _init() -> void:
	call_deferred("_run_checks")


func _run_checks() -> void:
	var scenes := _gather_scene_files(ROOT_DIR)
	scenes.sort()

	var total_issues := 0
	var scenes_with_issues := 0

	for scene_path in scenes:
		var issues := _check_scene(scene_path)
		if not issues.is_empty():
			scenes_with_issues += 1
			total_issues += issues.size()
			for issue in issues:
				push_error("%s -> %s" % [scene_path, issue])

	if total_issues > 0:
		printerr("Scene link check failed: %d issue(s) across %d scene(s)." % [total_issues, scenes_with_issues])
		quit(1)
	else:
		print("Scene link check passed for %d scene(s)." % scenes.size())
		quit(0)


func _gather_scene_files(root_path: String) -> Array:
	var result: Array = []
	var dir := DirAccess.open(root_path)
	if dir == null:
		push_error("Unable to open directory: %s" % root_path)
		return result

	dir.list_dir_begin()
	while true:
		var entry := dir.get_next()
		if entry == "":
			break
		if entry.begins_with("."):
			continue

		var full_path := root_path.path_join(entry)
		if dir.current_is_dir():
			result.append_array(_gather_scene_files(full_path))
		elif entry.ends_with(".tscn"):
			result.append(full_path)
	dir.list_dir_end()
	return result


func _check_scene(scene_path: String) -> Array:
	var issues: Array = []
	var resource := ResourceLoader.load(scene_path)
	if resource == null:
		issues.append("Failed to load resource.")
		return issues
	if not (resource is PackedScene):
		issues.append("Resource is not a PackedScene.")
		return issues

	var packed_scene: PackedScene = resource
	var instance := packed_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	if instance == null:
		issues.append("Failed to instantiate scene.")
		return issues

	var state := packed_scene.get_state()
	issues.append_array(_validate_connections(state, instance))
	instance.free()

	return issues


func _validate_connections(state: SceneState, root: Node) -> Array:
	var issues: Array = []
	var connection_count := state.get_connection_count()
	for idx in range(connection_count):
		var from_path := state.get_connection_source(idx)
		var to_path := state.get_connection_target(idx)
		var signal_name: StringName = state.get_connection_signal(idx)
		var method_name: StringName = state.get_connection_method(idx)

		var from_node := _resolve_node(root, from_path)
		var to_node := _resolve_node(root, to_path)

		if from_node == null:
			issues.append("Missing signal emitter at '%s' for signal '%s' -> method '%s'." % [str(from_path), String(signal_name), String(method_name)])
			continue
		if to_node == null:
			issues.append("Missing target node at '%s' for signal '%s' -> method '%s'." % [str(to_path), String(signal_name), String(method_name)])
			continue
		if signal_name == StringName():
			issues.append("Signal connection without a signal name on '%s'." % str(from_path))
			continue
		if method_name == StringName():
			issues.append("Signal '%s' from '%s' missing method name on '%s'." % [String(signal_name), str(from_path), str(to_path)])
			continue
		if not from_node.has_signal(signal_name):
			issues.append("'%s' does not define signal '%s' (target method '%s')." % [str(from_path), String(signal_name), String(method_name)])
			continue
		if not to_node.has_method(method_name):
			issues.append("'%s' missing method '%s' for signal '%s'." % [str(to_path), String(method_name), String(signal_name)])
	return issues


func _resolve_node(root: Node, raw_path) -> Node:
	var node_path = raw_path
	if not (node_path is NodePath):
		node_path = NodePath(str(raw_path))

	if str(node_path) == "." or node_path.is_empty():
		return root
	if root.has_node(node_path):
		return root.get_node(node_path)
	return null
