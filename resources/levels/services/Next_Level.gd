extends Area2D

# Level paths
const HOME_LEVEL_PATH: String = "res://resources/levels/home/Home_Level.tscn"
const OUTSIDE_LEVEL_PATH: String = "res://resources/levels/outside/Outside_Level.tscn"
const FACTORY_LEVEL_PATH: String = "res://resources/levels/factory/Factory_Level.tscn"

# Packed scenes loaded at runtime
@onready var HOME_LEVEL: PackedScene = load(HOME_LEVEL_PATH)
@onready var OUTSIDE_LEVEL: PackedScene = load(OUTSIDE_LEVEL_PATH)
@onready var FACTORY_LEVEL: PackedScene = load(FACTORY_LEVEL_PATH)

func _ready() -> void:
	Logger.log(self, "NextLevel trigger initialized on scene: " + str(get_tree().current_scene.scene_file_path))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Logger.log(self, "Player collided with NextLevel trigger (body entered)")
		transfer_player_to_next_level()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		Logger.log(self, "Player entered NextLevel trigger as area")
		transfer_player_to_next_level()


func transfer_player_to_next_level() -> void:
	var main = get_tree().root.get_node("Main") # Ensure this path is correct
	if main == null or not main.has_method("load_level"):
		push_error("Main node with 'load_level' method not found in scene tree!")
		return

	var current_level = main.get("current_level")
	var scene_file = current_level.scene_file_path if current_level else "UNKNOWN"
	Logger.log(self, "Current level detected: " + scene_file)

	var next_level: PackedScene = null
	var next_level_name: String = ""

	match scene_file:
		HOME_LEVEL_PATH:
			next_level = OUTSIDE_LEVEL
			next_level_name = "Outside Level"
		OUTSIDE_LEVEL_PATH:
			next_level = FACTORY_LEVEL
			next_level_name = "Factory Level"
		FACTORY_LEVEL_PATH:
			next_level = HOME_LEVEL
			next_level_name = "Home Level"
		_:
			push_error("Next level not determined. Unknown current level path: " + scene_file)

	if next_level:
		Logger.log(self, "Transferring player to next level: " + next_level_name)
		main.load_level(next_level)
