extends Entity

var player = null
var spawner: Node  # Set by spawner when instantiating

func _ready() -> void:
	add_to_group("enemies")
	
	# Log spawning using Logger
	Custom_Logger.log(self, "[Spawned] Name: %s | Position: %s" % [name, global_position])

func _on_died() -> void:
	if spawner:
		spawner.report_enemy_killed()
		Custom_Logger.log(self, "[Died] Reported to spawner.")
	else:
		Custom_Logger.log(self, "[Died] No spawner assigned.")
	
	self.die()
	Custom_Logger.log(self, "[Removed] Enemy has been removed from the scene.")
