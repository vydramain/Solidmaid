extends Area2D

@onready var home_level: PackedScene = load(Resource_Registry.LEVELS["HOME"])
@onready var outside_level: PackedScene = load(Resource_Registry.LEVELS["OUTSIDE"])
@onready var factory_level: PackedScene = load(Resource_Registry.LEVELS["FACTORY"])

func _ready() -> void:
	Custom_Logger.log(self, "NextLevel trigger initialized on scene: " + str(get_tree().current_scene.get_class()))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Custom_Logger.log(self, "Player collided with NextLevel trigger (body entered)")
		transfer_player_to_next_level()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		Custom_Logger.log(self, "Player entered NextLevel trigger as area")
		transfer_player_to_next_level()


func transfer_player_to_next_level() -> void:
	var main = get_tree().root.get_node("Main") # Ensure this path is correct
	if main == null or not main.has_method("load_level"):
		push_error("Main node with 'load_level' method not found in scene tree!")
		return
	
	var current_level = main.get("current_level")
	var scene_level_name = current_level.LEVEL_NAME if current_level else "UNKNOWN"
	Custom_Logger.log(self, "Current level detected: " + scene_level_name)
	
	var next_level: PackedScene = null
	var next_level_name: String = ""
	
	match scene_level_name:
		"HOME":
			next_level = outside_level
			next_level_name = "Outside Level"
		"OUTSIDE":
			next_level = factory_level
			next_level_name = "Factory Level"
		"FACTORY":
			next_level = home_level
			next_level_name = "Home Level"
		_:
			push_error("Next level not determined. Unknown current level path: " + scene_level_name)

	if next_level:
		Custom_Logger.log(self, "Transferring player to next level: " + next_level_name)
		main.load_level(next_level)
