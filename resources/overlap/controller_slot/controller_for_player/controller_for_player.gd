extends Node

const HUD_SCENE := preload("uid://cp1xgv8y1d6im")

var character
var loco
var throw_ability
var melee_ability
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
	var right_hand_pressed := Input.is_action_just_pressed("hand_right") or Input.is_action_just_pressed("attack")
	if right_hand_pressed:
		if not _handle_hand_slot(CarrySlots.SLOT_RIGHT):
			melee_ability.request_start(null)
			_trigger_camera_shake(0.25, 0.09)  # Empty-hand swing adds a subtle shake.
	var left_hand_pressed := Input.is_action_just_pressed("hand_left") or Input.is_action_just_pressed("throw")
	if left_hand_pressed:
		if not _handle_hand_slot(CarrySlots.SLOT_LEFT):
			if character and not character.request_throw():
				throw_ability.request_start(null)
				_trigger_camera_shake(0.35, 0.12)
	if Input.is_action_just_pressed("interact"):
		var interact_component = character.get_interactor()
		if interact_component:
			interact_component.interact()

func _handle_hand_slot(slot_name: String) -> bool:
	if character == null:
		return false
	var hand_label := slot_name.capitalize()
	var slots: CarrySlots = character.get_carry_slots()
	if slots:
		var slot_item := slots.get_item(slot_name)
		if slot_item:
			var did_throw: bool = character.request_throw(slot_name)
			if did_throw:
				Custom_Logger.debug(self, "Персонаж %s взаимодействует с объектом %s с помощью %s" % [character.name, slot_item.name, hand_label])
				_trigger_camera_shake(0.35, 0.12)  # Throwing a carried object nudges the camera.
			return did_throw
	var target = _get_interactor_target()
	if target:
		if target.has_method("interact"):
			target.interact(character)
			Custom_Logger.debug(self, "Персонаж %s взаимодействует с объектом %s с помощью %s" % [character.name, target.name, hand_label])
			_trigger_camera_shake(0.2, 0.08)  # Interaction feedback.
			return true
		if target is Node and (target as Node).is_in_group("interactable"):
			(target as Node).emit_signal.call_deferred("interacted", character)
			Custom_Logger.debug(self, "Персонаж %s взаимодействует с объектом %s с помощью %s" % [character.name, target.name, hand_label])
			_trigger_camera_shake(0.2, 0.08)
			return true

	return false

func _get_interactor_target():
	var current_interactor: Interactor = character.get_interactor()
	if current_interactor:
		return current_interactor.get_current_target()
	return null

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


func init(ch):
	character = ch
	loco = ch.body
	throw_ability = ch.get_ability("AbilityToThrow")
	melee_ability = ch.get_ability("AbilityToMelee")
	if character and not character.interactor_ready.is_connected(_on_interactor_ready):
		character.interactor_ready.connect(_on_interactor_ready)
	_ensure_hud()
	_bind_hud_character()
	vision_rig = character.ensure_vision_rig()
	vision_camera = character.get_vision_camera()
	if vision_camera:
		vision_camera.current = true
	_on_interactor_ready(character.get_interactor())
