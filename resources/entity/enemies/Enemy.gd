extends "res://resources/entity/Entity.gd"

var player = null
var spawner: Node  # set by spawner when instantiating

func _ready() -> void:
	add_to_group("enemies")
	
	print("[Spawned] %s at %s" % [name, global_position])

func _process(delta: float) -> void:
	if player:
		var direction = (player.global_position - global_position).normalized()
		position += direction * SPEED * delta


func _on_died() -> void:
	if spawner:
		spawner.report_enemy_killed()
	self.die()
