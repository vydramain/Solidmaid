extends Entity
class_name Enemy

@onready var hitbox: Area2D = $Hitbox


func _ready() -> void:
	if hitbox:
		hitbox.monitoring = true
		hitbox.monitorable = true
		hitbox.collision_layer = 4
		hitbox.collision_mask = hitbox.collision_mask | 8  # ensure we detect bricks
		if not hitbox.is_connected("area_entered", Callable(self, "_on_hurtbox_area_entered")):
			hitbox.connect("area_entered", Callable(self, "_on_hurtbox_area_entered"))

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area and area.is_in_group("Hurtboxes"):
		self.receive_damage(100)
