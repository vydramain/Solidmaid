extends Node2D
class_name Home_Level

# Ensure Logger.gd is loaded in your project and autoloaded or accessible
# This script replaces all `print` calls with Logger.log for consistency

var _floor_physic_lines: Array[Node] = []

func _ready():
	# Log the level load event
	Custom_Logger.log(self, "Level loaded: '%s'" % self.name)
	
	# Log number of child nodes
	var children_count = get_child_count()
	Custom_Logger.log(self, "Number of children: %d" % children_count)
	
	# Log each child with its class type
	for child in get_children():
		Custom_Logger.log(self, "Child node detected -> Name: '%s', Type: '%s'" % [child.name, child.get_class()])
	
	_floor_physic_lines = get_tree().get_nodes_in_group("FloorPhysicLines")
	Custom_Logger.log(self, "Received '%d' floor physic lines" % [_floor_physic_lines.size()])
	
	# Log music playback
	if MUSIC_PLAYER:
		Custom_Logger.log(self, "Playing next music track in 'home' category")
		MUSIC_PLAYER.play_next('home')
	else:
		Custom_Logger.log(self, "MUSIC_PLAYER is not defined or accessible")

func get_floor_physic_line_below(y: float) -> Physic_Line:
	var candidate: Physic_Line = null
	var min_dist := INF
	for flr in _floor_physic_lines:
		if flr.get_floor_y() >= y:
			var dist = flr.get_floor_y() - y
			if dist < min_dist:
				min_dist = dist
				candidate = flr
	return candidate
