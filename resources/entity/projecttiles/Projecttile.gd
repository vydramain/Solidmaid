extends "res://resources/entity/Entity.gd"

func _physics_process(delta: float) -> void:
	#var direction = Vector2.RIGHT.rotated(rotation)
	#global_position += SPEED * direction * delta
	
	if global_position.length() > 5000:
		destroy()


func destroy() -> void:
	queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:
	destroy()

func _on_hitbox_body_entered(body: Node2D) -> void:
	destroy()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	destroy()
