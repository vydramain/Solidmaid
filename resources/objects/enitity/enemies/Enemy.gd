extends Entity


func _on_hurtbox_area_entered(area: Area2D) -> void:
	var found_group = area.get_groups()
	if (area.is_in_group("Hitboxes")):
		self.receive_damage(100)
