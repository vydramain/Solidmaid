extends Node2D

# Make sure your Logger.gd script is loaded somewhere in the project
# Example usage: Logger.log(self, "Some message")

func _ready():
	# Log scene load
	Logger.log(self, "Level loaded successfully.")

	# Log basic info about this node
	Logger.log(self, "Node name: %s | Children count: %d" % [self.name, get_child_count()])

	# Log each child node with its type
	for child in get_children():
		Logger.log(self, "Child detected -> Name: %s | Type: %s | Path: %s" % [child.name, child.get_class(), child.get_path()])

	# Play next music track and log the action
	if MUSIC_PLAYER:
		MUSIC_PLAYER.play_next('work')
		Logger.log(self, "Triggered MUSIC_PLAYER to play next track: 'work'.")
	else:
		Logger.log(self, "MUSIC_PLAYER not found. Cannot play track.")
