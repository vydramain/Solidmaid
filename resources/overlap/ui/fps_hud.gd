extends CanvasLayer

@export var normal_crosshair_color: Color = Color(1, 1, 1, 0.35)
@export var highlight_crosshair_color: Color = Color(1, 0.85, 0.45, 0.95)
@export var default_prompt_text: String = "Interact"

@onready var _crosshair: Control = $HudRoot/Crosshair
@onready var _prompt_panel: Panel = $HudRoot/PromptPanel
@onready var _prompt_label: Label = $HudRoot/PromptPanel/MarginContainer/PromptLabel

var _interactor: Interactor


func _ready() -> void:
	_prompt_panel.visible = false
	_apply_crosshair_color(false)


func bind_interactor(interactor: Interactor) -> void:
	if _interactor and _interactor.target_changed.is_connected(_on_interactor_target_changed):
		_interactor.target_changed.disconnect(_on_interactor_target_changed)
	_interactor = interactor
	if _interactor:
		_interactor.target_changed.connect(_on_interactor_target_changed)
		_on_interactor_target_changed(_interactor.get_current_target())
	else:
		_on_interactor_target_changed(null)


func _on_interactor_target_changed(target) -> void:
	var valid_target: bool = target != null and is_instance_valid(target)
	_apply_crosshair_color(valid_target)
	if not valid_target:
		_prompt_panel.visible = false
		return
	var prompt_text := default_prompt_text
	if target.has_method("get_interact_prompt"):
		prompt_text = str(target.get_interact_prompt())
	elif target.has_meta("prompt_text"):
		prompt_text = str(target.get_meta("prompt_text"))
	_prompt_label.text = prompt_text
	_prompt_panel.visible = prompt_text.length() > 0


func _apply_crosshair_color(is_highlighted: bool) -> void:
	var color := highlight_crosshair_color if is_highlighted else normal_crosshair_color
	_crosshair.modulate = color
