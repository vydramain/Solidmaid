extends Area3D
class_name HitboxAbility

const HurtboxAffordance := preload("uid://btxlrex6cpcfd")

@export_range(0, 9999, 1, "suffix:hp") var damage: int = 10
@export var impulse: float = 0.0
@export var source_ref: Node
@export var hit_group: StringName = &"default"
@export var enabled: bool = true
@export var one_hit_only: bool = true
@export_range(0.0, 10.0, 0.01, "suffix:s") var lifetime: float = 0.1

var _has_fired := false


func _ready() -> void:
	monitoring = true
	monitorable = false
	area_entered.connect(_on_area_entered)
	if lifetime > 0.0:
		var tree := get_tree()
		if tree:
			var timer := tree.create_timer(lifetime)
			timer.timeout.connect(_expire_hitbox)


func _expire_hitbox() -> void:
	if not is_inside_tree():
		return
	_disable_hitbox()
	queue_free()


func _disable_hitbox() -> void:
	enabled = false
	monitoring = false
	monitorable = false


func _on_area_entered(area: Area3D) -> void:
	if not enabled or area == null:
		return
	if not (area is HurtboxAffordance):
		return
	if _has_fired and one_hit_only:
		return

	var hit_info := {
		"damage": damage,
		"impulse": impulse,
		"source": source_ref,
		"position": global_transform.origin,
		"group": hit_group,
	}

	area.receive_hit(hit_info)
	_has_fired = true
	if one_hit_only:
		_disable_hitbox()
