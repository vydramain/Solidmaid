extends Node

const HUD_SCENE := preload("uid://cp1xgv8y1d6im")

var character
var loco
var wants_capture := true
var vision_rig
var vision_camera: Camera3D
var hud: CanvasLayer


func _ready() -> void:
	if wants_capture:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _exit_tree() -> void:
	if character and character.interactor_ready.is_connected(_on_interactor_ready):
		character.interactor_ready.disconnect(_on_interactor_ready)

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		loco.set_look_delta(event.relative)

	# Release capture on Esc
	if event.is_action_pressed("ui_cancel"):
		wants_capture = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Re-capture on click
	elif event is InputEventMouseButton and not wants_capture and event.pressed:
		wants_capture = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		if wants_capture and not get_tree().paused:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(_dt):
	var move = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	)
	loco.set_move_input(move)
	var drop_modifier := Input.is_action_pressed("drop_modifier")
	var right_hand_pressed := Input.is_action_just_pressed("hand_right")
	if right_hand_pressed:
		var modifier := Character.HAND_MODIFIER_DROP if drop_modifier else Character.HAND_MODIFIER_NONE
		_handle_hand_slot(CarrySlots.SLOT_RIGHT, modifier)
	var left_hand_pressed := Input.is_action_just_pressed("hand_left")
	if left_hand_pressed:
		var modifier := Character.HAND_MODIFIER_DROP if drop_modifier else Character.HAND_MODIFIER_NONE
		_handle_hand_slot(CarrySlots.SLOT_LEFT, modifier)


func _handle_hand_slot(slot_name: String, modifier: StringName = Character.HAND_MODIFIER_NONE) -> bool:
	if character == null:
		return false
	var hand_label := slot_name.capitalize()
	var result = character.interact_hand(slot_name, modifier)
	if typeof(result) != TYPE_DICTIONARY:
		return false
	if result.is_empty():
		return false
	var action: StringName = result.get("action", Character.HAND_ACTION_NONE)
	var subject: Node = result.get("subject")
	if action == Character.HAND_ACTION_NONE:
		return false

	match action:
		Character.HAND_ACTION_THROW:
			if subject:
				Custom_Logger.debug(self, "Персонаж %s бросает %s %s рукой" % [character.name, subject.name, hand_label])
			_trigger_camera_shake(0.35, 0.12)
			_trigger_hitstop(0.05)
			return true
		Character.HAND_ACTION_PICKUP:
			if subject:
				Custom_Logger.debug(self, "Персонаж %s поднимает %s %s рукой" % [character.name, subject.name, hand_label])
			_trigger_camera_shake(0.2, 0.08)
			_trigger_hitstop(0.04, 0.25)
			return true
		Character.HAND_ACTION_MELEE:
			if subject:
				Custom_Logger.debug(self, "Персонаж %s атакует с помощью %s (%s рука)" % [character.name, subject.name, hand_label])
			# Melee ability already triggers feedback, keep light touch.
			return true
		Character.HAND_ACTION_INTERACT:
			if subject:
				Custom_Logger.debug(self, "Персонаж %s взаимодействует с объектом %s %s рукой" % [character.name, subject.name, hand_label])
			_trigger_camera_shake(0.2, 0.08)
			_trigger_hitstop(0.04, 0.25)
			return true
		Character.HAND_ACTION_DROP:
			if subject:
				Custom_Logger.debug(self, "Персонаж %s отпускает %s рукой предмет %s" % [character.name, hand_label, subject.name])
			return true

	return false

func _ensure_hud() -> void:
	if hud:
		return
	hud = HUD_SCENE.instantiate()
	add_child(hud)
	_bind_hud_character()

func _on_interactor_ready(new_interactor: Interactor) -> void:
	if hud:
		hud.bind_interactor(new_interactor)


func _bind_hud_character() -> void:
	if hud and character and hud.has_method("bind_character"):
		hud.bind_character(character)


func _trigger_camera_shake(strength: float, duration: float) -> void:
	if character:
		character.trigger_camera_shake(strength, duration)


func _trigger_hitstop(duration: float = 0.06, time_scale: float = 0.2) -> void:
	if character:
		character.trigger_hitstop(duration, time_scale)


func init(ch):
	character = ch
	loco = ch.body
	if character and not character.interactor_ready.is_connected(_on_interactor_ready):
		character.interactor_ready.connect(_on_interactor_ready)
	_ensure_hud()
	_bind_hud_character()
	vision_rig = character.ensure_vision_rig()
	vision_camera = character.get_vision_camera()
	if vision_camera:
		vision_camera.current = true
	_on_interactor_ready(character.get_interactor())
