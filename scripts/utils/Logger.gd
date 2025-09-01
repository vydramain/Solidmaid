extends Node

class_name Logger

static func log(caller: Object, msg: String) -> void:
	var current_scene = caller.get_tree().current_scene
	var scene_name = current_scene.name if current_scene else "NO_CURRENT_SCENE"
	var place = str(caller.get_path())
	print("[{scene} | {place}] {msg}".format({
		"scene": scene_name,
		"place": place,
		"msg": msg
	}))
