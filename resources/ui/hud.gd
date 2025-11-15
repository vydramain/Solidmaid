extends CanvasLayer

@export var normal_crosshair_color: Color = Color(1, 1, 1, 0.35)
@export var highlight_crosshair_color: Color = Color(1, 0.85, 0.45, 0.95)

@onready var _hud_root: Control = $HudRoot
@onready var _crosshair: Control = $HudRoot/Crosshair
@onready var _hp_label: Label = $HudRoot/Vitality/VBoxContainer/Hp
@onready var _hp_max_label: Label = $HudRoot/Vitality/VBoxContainer/HpMax
@onready var _abilities_container: VBoxContainer = $HudRoot/Abilities/VBoxContainer
@onready var _hand_left_label: Label = $HudRoot/Carries/VBoxContainer/HandLeft
@onready var _hand_right_label: Label = $HudRoot/Carries/VBoxContainer/HandRight
@onready var _loc_speed_label: Label = $HudRoot/Locomotion/VBoxContainer/Speed
@onready var _loc_velocity_label: Label = $HudRoot/Locomotion/VBoxContainer/Velocity
@onready var _loc_direction_label: Label = $HudRoot/Locomotion/VBoxContainer/Direction

var _interactor: Interactor
var _character
var _vitality
var _carry_slots: CarrySlots
var _locomotion: Locomotion
var _ability_labels: Array[Label] = []
var _reference_viewport_size: Vector2 = Vector2.ZERO


func _ready() -> void:
	_apply_crosshair_color(false)
	set_process(true)
	_cache_reference_viewport()
	_update_scale_from_window()
	var viewport := get_viewport()
	if viewport:
		viewport.size_changed.connect(_on_viewport_size_changed)


func bind_interactor(interactor: Interactor) -> void:
	if _interactor and _interactor.target_changed.is_connected(_on_interactor_target_changed):
		_interactor.target_changed.disconnect(_on_interactor_target_changed)
	_interactor = interactor
	if _interactor:
		_interactor.target_changed.connect(_on_interactor_target_changed)
		_on_interactor_target_changed(_interactor.get_current_target())
	else:
		_on_interactor_target_changed(null)


func bind_character(character) -> void:
	_character = character
	if character and character.has_method("get_vitality"):
		_vitality = character.get_vitality()
	elif character and character.has_node("Vitality"):
		_vitality = character.get_node("Vitality")
	else:
		_vitality = null
	_carry_slots = character.get_carry_slots() if character and character.has_method("get_carry_slots") else null
	_locomotion = character if character and character is Locomotion else null
	_setup_vitality_signals()
	_update_vitality_labels()
	_refresh_ability_list()


func _process(_dt: float) -> void:
	_update_carry_labels()
	_update_locomotion_labels()


func _setup_vitality_signals() -> void:
	if not _vitality:
		return
	if not _vitality.damaged.is_connected(_on_vitality_changed):
		_vitality.damaged.connect(_on_vitality_changed)
	if not _vitality.died.is_connected(_on_vitality_changed):
		_vitality.died.connect(_on_vitality_changed)


func _on_vitality_changed(_amount = 0, _source = null) -> void:
	_update_vitality_labels()


func _update_vitality_labels() -> void:
	if not _vitality:
		_hp_label.text = "Hp: --"
		_hp_max_label.text = "Hp Max: --"
		return
	_hp_label.text = "Hp: %.0f" % _vitality.hp
	_hp_max_label.text = "Hp Max: %.0f" % _vitality.max_hp


func _refresh_ability_list() -> void:
	for label in _ability_labels:
		if is_instance_valid(label):
			label.queue_free()
	_ability_labels.clear()
	if not _character:
		return
	var abilities_node = _character.get_node_or_null("Abilities")
	if not abilities_node:
		return
	for ability_node in abilities_node.get_children():
		var label := Label.new()
		label.label_settings = load("uid://b62gn8gde8nkq")
		label.text = "- %s" % ability_node.name
		_abilities_container.add_child(label)
		_ability_labels.append(label)


func _update_carry_labels() -> void:
	if not _carry_slots:
		_hand_left_label.text = "_ :Left"
		_hand_right_label.text = "_ :Right"
		return
	_hand_left_label.text = "%s :Left" % _format_slot_item(CarrySlots.SLOT_LEFT)
	_hand_right_label.text = "%s :Right" % _format_slot_item(CarrySlots.SLOT_RIGHT)


func _format_slot_item(slot_name: String) -> String:
	var item: Node3D = _carry_slots.get_item(slot_name)
	if item and is_instance_valid(item):
		return item.name
	return "_"


func _update_locomotion_labels() -> void:
	if not _locomotion:
		_loc_speed_label.text = "Speed: --"
		_locomotion_velocity_text(Vector3.ZERO)
		_loc_direction_label.text = "Direction: (0,0)"
		return
	var vel: Vector3 = _locomotion.velocity
	_loc_speed_label.text = "Speed: %.2f" % vel.length()
	_locomotion_velocity_text(vel)
	var move_dir := Vector2(vel.x, vel.z)
	_loc_direction_label.text = "Direction: (%.2f, %.2f)" % [move_dir.x, move_dir.y]


func _locomotion_velocity_text(vel: Vector3) -> void:
	_loc_velocity_label.text = "Velocity: (%.2f, %.2f, %.2f)" % [vel.x, vel.y, vel.z]


func _on_interactor_target_changed(target) -> void:
	var valid_target: bool = target != null and is_instance_valid(target)
	_apply_crosshair_color(valid_target)


func _apply_crosshair_color(is_highlighted: bool) -> void:
	var color := highlight_crosshair_color if is_highlighted else normal_crosshair_color
	_crosshair.modulate = color


func _cache_reference_viewport() -> void:
	var width: Variant = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height: Variant = ProjectSettings.get_setting("display/window/size/viewport_height")
	if typeof(width) == TYPE_INT or typeof(width) == TYPE_FLOAT:
		_reference_viewport_size.x = float(width)
	if typeof(height) == TYPE_INT or typeof(height) == TYPE_FLOAT:
		_reference_viewport_size.y = float(height)
	if _reference_viewport_size.x <= 0.0:
		_reference_viewport_size.x = 1.0
	if _reference_viewport_size.y <= 0.0:
		_reference_viewport_size.y = 1.0


func _on_viewport_size_changed() -> void:
	_update_scale_from_window()


func _update_scale_from_window() -> void:
	if not _hud_root:
		return
	var viewport := get_viewport()
	if viewport == null:
		return
	var actual_size := viewport.get_visible_rect().size
	if actual_size.x <= 0.0 or actual_size.y <= 0.0:
		return
	var scale_vec := Vector2(
		actual_size.x / _reference_viewport_size.x,
		actual_size.y / _reference_viewport_size.y
	)
	if scale_vec.x == 0.0 or scale_vec.y == 0.0:
		return
	var rounded_scale := Vector2(
		max(1.0, round(scale_vec.x)),
		max(1.0, round(scale_vec.y))
	)
	_hud_root.scale = Vector2(1.0 / rounded_scale.x, 1.0 / rounded_scale.y)
	var pos_offset := (actual_size - (_reference_viewport_size * rounded_scale)) * 0.5
	_hud_root.position = -pos_offset / rounded_scale
