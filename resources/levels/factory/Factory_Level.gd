extends Node2D

@onready var enemy_spawner: Node = $EnemySpawner


func _ready():
	print("Loaded level: ", self.name)
	print("Children count: ", get_child_count())
	for child in get_children():
		print(" - ", child.name, ": ", child.get_class())
	
	MUSIC_PLAYER.play_next('factory')

func _exit_tree() -> void:
	print("Node exiting tree: " + name)
	
	var main = get_tree().root.get_node("Main")
	if main == null:
		print("Main not found")
		return

	var current_level = main.get("current_level")
	if current_level == null:
		print("current_level is null in Main")
		return
	
	if enemy_spawner.has_method("kill_all_enemies"):
		enemy_spawner.kill_all_enemies()
	else:
		print("enemy_spawner has no method 'kill_all_enemies'")
