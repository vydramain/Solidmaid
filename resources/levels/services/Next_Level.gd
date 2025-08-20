extends Area2D

const HOME_LEVEL_PATH: String = "res://resources/levels/home/Home_Level.tscn"
const OUTSIDE_LEVEL_PATH: String = "res://resources/levels/outside/Outside_Level.tscn"
const FACTORY_LEVEL_PATH: String = "res://resources/levels/factory/Factory_Level.tscn"

@onready var HOME_LEVEL: PackedScene = load(HOME_LEVEL_PATH)
@onready var OUTSIDE_LEVEL: PackedScene = load(OUTSIDE_LEVEL_PATH)
@onready var FACTORY_LEVEL: PackedScene = load(FACTORY_LEVEL_PATH)


func _ready() -> void:
	print("NextLevel loaded on scene: " + get_tree().current_scene.scene_file_path)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Player entered NextLevel trigger")
		transfer_player_to_next_level()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		print("Player (as area) entered NextLevel trigger")
		transfer_player_to_next_level()


func transfer_player_to_next_level() -> void:
	var main = get_tree().root.get_node("Main") # Adjust path if needed
	if main == null or not main.has_method("load_level"):
		push_error("Main node with 'load_level' method not found in scene tree!")
		return

	var current_level = main.get("current_level")
	var scene_file = current_level.scene_file_path if current_level else ""
	print("Current level: ", scene_file)

	var next_level: PackedScene = null
	if scene_file == HOME_LEVEL_PATH:
		next_level = OUTSIDE_LEVEL
	if scene_file == OUTSIDE_LEVEL_PATH:
		next_level = FACTORY_LEVEL
	if scene_file == FACTORY_LEVEL_PATH:
		next_level = HOME_LEVEL

	if next_level:
		main.load_level(next_level)
	else:
		push_error("Unable to determine next level from: " + str(scene_file))
