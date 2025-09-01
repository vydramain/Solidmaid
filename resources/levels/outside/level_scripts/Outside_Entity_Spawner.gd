extends Node
class_name Outside_Entity_Spawner

# Spawns a new entity at the specified position with optional z-index.
# Logs the request and the result with detailed information.
func spawn_new_entity_at(entity: PackedScene, new_position: Vector2i, new_z_index: int = 0) -> Node2D:
	# Log the spawn request with all relevant details
	Logger.log(self, "[Spawn Request] Scene: %s | Target Position: (%d, %d) | Z-Index: %d" %
		[str(entity), new_position.x, new_position.y, new_z_index])
	
	# Instantiate the entity
	var new_entity: Node2D = entity.instantiate()
	new_entity.z_index = new_z_index
	add_child(new_entity)
	
	# Ensure position is Vector2 for Node2D
	new_entity.global_position = Vector2(new_position.x, new_position.y)
	
	# Log the successful spawn with resulting entity details
	Logger.log(self, "[Spawn Success] Entity: %s | Global Position: (%f, %f) | Z-Index: %d" %
		[str(new_entity), new_entity.global_position.x, new_entity.global_position.y, new_entity.z_index])
	
	return new_entity
