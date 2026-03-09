extends Node
class_name VitalityHurtboxAdapter

@export_node_path("HurtboxAffordance") var hurtbox_path: NodePath = NodePath("../Hurtbox")
@export_node_path("Node") var vitality_path: NodePath = NodePath("../Vitality")

var _hurtbox: HurtboxAffordance
var _vitality: Vitality


func _ready() -> void:
	_hurtbox = get_node_or_null(hurtbox_path) as HurtboxAffordance
	_vitality = get_node_or_null(vitality_path) as Vitality
	if _hurtbox == null:
		push_warning("VitalityHurtboxAdapter: missing hurtbox at %s" % hurtbox_path)
		return
	if _vitality == null:
		push_warning("VitalityHurtboxAdapter: missing vitality at %s" % vitality_path)
		return
	if not _hurtbox.on_hurt.is_connected(_on_hurtbox_hurt):
		_hurtbox.on_hurt.connect(_on_hurtbox_hurt)


func _on_hurtbox_hurt(hit_info: Dictionary) -> void:
	if _vitality == null:
		return
	var amount := float(hit_info.get("damage", 0.0))
	var source = hit_info.get("source", null)
	_vitality.apply_damage(amount, source)
