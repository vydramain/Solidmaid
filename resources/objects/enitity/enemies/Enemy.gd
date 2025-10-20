extends Entity


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if (area.is_in_group("Hurtboxes")):
		self.receive_damage(100)
