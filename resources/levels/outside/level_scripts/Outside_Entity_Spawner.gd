extends Node
class_name Outside_Entity_Spawner


func spawn_new_entity_at(entity: PackedScene, new_position: Vector2i, new_z_index: int = 0) -> Node2D:
	Logger.log(self, "requested: scene=" + str(entity) + " pos=" + str(new_position) + " z=" + str(new_z_index))
	var new_entity = entity.instantiate()
	new_entity.z_index = new_z_index
	add_child(new_entity)
	# ensure position is a Vector2 for Node2D
	new_entity.global_position = Vector2(new_position.x, new_position.y)
	Logger.log(self, "spawned: " + str(new_entity) + " global_pos=" + str(new_entity.global_position))
	return new_entity
