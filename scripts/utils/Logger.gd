extends Node
class_name Logger

static func log(caller: Object, msg: String) -> void:
	if not caller:
		print("[NO_CALLER] %s" % msg)
		return
	
	var scene_name = "NO_CURRENT_SCENE"
	if caller.get_tree() and caller.get_tree().current_scene:
		scene_name = caller.get_tree().current_scene.name

	var place = "NO_PATH"
	if caller.has_method("get_path"):
		place = str(caller.get_path())

	print("[{scene} | {place}] {msg}".format({
		"scene": scene_name,
		"place": place,
		"msg": msg
	}))
