extends Node
class_name Logger

static func log(caller: Object, msg: String) -> void:
	if not caller:
		print("[NO_CALLER] %s" % msg)
		return
	
	var scene_name = "NO_CURRENT_SCENE"
	var place = "NO_PATH"
	
	# Check if caller has access to scene tree (is a Node)
	if caller.has_method("get_tree") and caller.get_tree() and caller.get_tree().current_scene:
		scene_name = caller.get_tree().current_scene.name
	
	if caller.has_method("get_path"):
		place = str(caller.get_path())
	elif caller.has_method("get_script") and caller.get_script():
		# For RefCounted objects, show the class name instead
		place = caller.get_script().get_global_name()
		if place.is_empty():
			place = str(caller.get_class())
	
	print("[{scene} | {place}] {msg}".format({
		"scene": scene_name,
		"place": place,
		"msg": msg
	}))
