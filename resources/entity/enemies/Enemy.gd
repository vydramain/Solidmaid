extends "res://resources/entity/Entity.gd"

var player = null
var spawner: Node  # Set by spawner when instantiating

func _ready() -> void:
	add_to_group("enemies")
	
	# Log spawning using Logger
	Custom_Logger.log(self, "[Spawned] Name: %s | Position: %s" % [name, global_position])

func _process(delta: float) -> void:
	if player:
		var direction = (player.global_position - global_position).normalized()
		position += direction * SPEED * delta
		
		# Optional movement debug
		# Custom_Logger.log(self, "[Movement] Moving towards player at %s | Delta: %f" % [player.global_position, delta])

func _on_died() -> void:
	if spawner:
		spawner.report_enemy_killed()
		Custom_Logger.log(self, "[Died] Reported to spawner.")
	else:
		Custom_Logger.log(self, "[Died] No spawner assigned.")
	
	self.die()
	Custom_Logger.log(self, "[Removed] Enemy has been removed from the scene.")
