extends Node2D

# Ensure Logger.gd is loaded in your project and autoloaded or accessible
# This script replaces all `print` calls with Logger.log for consistency

func _ready():
	# Log the level load event
	Logger.log(self, "Level loaded: '%s'" % self.name)
	
	# Log number of child nodes
	var children_count = get_child_count()
	Logger.log(self, "Number of children: %d" % children_count)
	
	# Log each child with its class type
	for child in get_children():
		Logger.log(self, "Child node detected -> Name: '%s', Type: '%s'" % [child.name, child.get_class()])
	
	# Log music playback
	if MUSIC_PLAYER:
		Logger.log(self, "Playing next music track in 'home' category")
		MUSIC_PLAYER.play_next('home')
	else:
		Logger.log(self, "MUSIC_PLAYER is not defined or accessible")
