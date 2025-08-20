extends Node2D

func _ready():
	print("Loaded level: ", self.name)
	print("Children count: ", get_child_count())
	
	for child in get_children():
		print(" - ", child.name, ": ", child.get_class())
	
	MUSIC_PLAYER.play_next('home')
