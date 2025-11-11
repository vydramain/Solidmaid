extends Node2D
class_name Outside_Level

const LEVEL_NAME: String = "OUTSIDE"

# Make sure your Logger.gd script is loaded somewhere in the project
# Example usage: Custom_Logger.log(self, "Some message")

func _ready():
	# Log the initialization process starting
	Custom_Logger.log(self, "_ready() function started - initializing scene")
	
	# Log scene setup completion
	Custom_Logger.log(self, "Scene initialization completed - Node2D ready for operations")
	
	# Log node structure analysis
	Custom_Logger.log(self, "Analyzing node structure: '%s' has %d child nodes" % [self.name, get_child_count()])
	
	# Log detailed child node information
	if get_child_count() > 0:
		Custom_Logger.log(self, "Enumerating child nodes for scene hierarchy mapping:")
		for child in get_children():
			Custom_Logger.log(self, "Found child node: '%s' [%s] at path %s" % [child.name, child.get_class(), child.get_path()])
	else:
		Custom_Logger.log(self, "No child nodes found - scene contains only root Node2D")
	
	# Log music system interaction
	if MUSIC_PLAYER:
		Custom_Logger.log(self, "MUSIC_PLAYER reference found - attempting to start 'work' track")
		MUSIC_PLAYER.play_next('work')
		Custom_Logger.log(self, "Successfully requested MUSIC_PLAYER to play 'work' track")
	else:
		Custom_Logger.log(self, "MUSIC_PLAYER reference is null - music playback unavailable")
	
	# Log completion of _ready() function
	Custom_Logger.log(self, "_ready() function completed - scene fully initialized")
