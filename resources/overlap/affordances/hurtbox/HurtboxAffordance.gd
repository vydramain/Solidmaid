extends Area3D
class_name HurtboxAffordance

@export var owner_ref: Node
@export var group: StringName = &"default"
@export var enabled: bool = true

signal on_hurt(hit_info)


func _ready() -> void:
	monitoring = false
	monitorable = true
	collision_layer = 0


func receive_hit(hit_info: Dictionary) -> void:
	if not enabled:
		return
	var payload := hit_info.duplicate()
	payload["group"] = group
	payload["owner"] = owner_ref
	on_hurt.emit(payload)
