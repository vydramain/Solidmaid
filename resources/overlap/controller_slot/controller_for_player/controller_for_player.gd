extends Node

const HUD_SCENE := preload("uid://cp1xgv8y1d6im")
const HEAVY_HOLD_SECONDS := 0.5

var character
var loco
var wants_capture := true
var vision_rig
var vision_camera: Camera3D
var hud: CanvasLayer
var _queued_hand_presses := {}


func _ready() -> void:
	if wants_capture:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _exit_tree() -> void:
	if character and character.interactor_ready.is_connected(on_interactor_ready):
		character.interactor_ready.disconnect(on_interactor_ready)

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
	
	process_hand_input(CarrySlots.SLOT_RIGHT, "hand_right", drop_modifier)
	process_hand_input(CarrySlots.SLOT_LEFT, "hand_left", drop_modifier)


func resolve_hand_modifier(drop_modifier: bool, heavy_modifier: bool) -> StringName:
	if drop_modifier:
		return Character.HAND_MODIFIER_DROP
	if heavy_modifier:
		return Character.HAND_MODIFIER_HEAVY
	return Character.HAND_MODIFIER_NONE


func process_hand_input(slot_name: String, action_name: StringName, drop_modifier: bool) -> void:
	if character == null:
		return
	
	var just_pressed := Input.is_action_just_pressed(action_name)
	var pressed := Input.is_action_pressed(action_name)
	var just_released := Input.is_action_just_released(action_name)
	
	if just_pressed:
		if should_charge_heavy(slot_name, drop_modifier):
			_queued_hand_presses[slot_name] = {
				"started_at": Time.get_ticks_msec(),
				"heavy_fired": false,
			}
		else:
			handle_hand_slot(slot_name, resolve_hand_modifier(drop_modifier, false))
			return
	
	if pressed and _queued_hand_presses.has(slot_name):
		var state: Dictionary = _queued_hand_presses[slot_name]
		if not bool(state.get("heavy_fired", false)):
			var started_at := int(state.get("started_at", 0))
			var held_for := (Time.get_ticks_msec() - started_at) / 1000.0
			if held_for >= HEAVY_HOLD_SECONDS:
				handle_hand_slot(slot_name, Character.HAND_MODIFIER_HEAVY)
				state["heavy_fired"] = true
				_queued_hand_presses[slot_name] = state
	
	if just_released and _queued_hand_presses.has(slot_name):
		var state: Dictionary = _queued_hand_presses[slot_name]
		if not bool(state.get("heavy_fired", false)):
			handle_hand_slot(slot_name, Character.HAND_MODIFIER_NONE)
		_queued_hand_presses.erase(slot_name)


func should_charge_heavy(slot_name: String, drop_modifier: bool) -> bool:
	if drop_modifier or character == null:
		return false
	var carry_slots: CarrySlots = character.get_carry_slots()
	if carry_slots == null:
		return false
	var held_item := carry_slots.get_item(slot_name)
	if held_item == null:
		return false
	return character.item_has_affordance(held_item, Character.AFFORDANCE_MELEE)


func handle_hand_slot(slot_name: String, modifier: StringName = Character.HAND_MODIFIER_NONE) -> bool:
	if character == null:
		return false
	
	var hand_label := slot_name.capitalize()
	var result = character.interact_hand(slot_name, modifier)
	
	if typeof(result) != TYPE_DICTIONARY or result.is_empty():
		return false
	
	var action: StringName = result.get("action", Character.HAND_ACTION_NONE)
	var subject: Node = result.get("subject")
	
	if action == Character.HAND_ACTION_NONE:
		return false
	
	match action:
		Character.HAND_ACTION_THROW:
			if subject:
				Custom_Logger.debug(self, "Персонаж %s бросает %s %s рукой" % [character.name, subject.name, hand_label])
			trigger_camera_shake(0.35, 0.12)
			trigger_hitstop(0.05)
			return true
		Character.HAND_ACTION_PICKUP:
			if subject:
				Custom_Logger.debug(self, "Персонаж %s поднимает %s %s рукой" % [character.name, subject.name, hand_label])
			trigger_camera_shake(0.2, 0.08)
			trigger_hitstop(0.04, 0.25)
			return true
		Character.HAND_ACTION_MELEE:
			if subject:
				Custom_Logger.debug(self, "Персонаж %s атакует с помощью %s (%s рука)" % [character.name, subject.name, hand_label])
			# Melee ability already triggers feedback, keep light touch.
			return true
		Character.HAND_ACTION_INTERACT:
			if subject:
				Custom_Logger.debug(self, "Персонаж %s взаимодействует с объектом %s %s рукой" % [character.name, subject.name, hand_label])
			trigger_camera_shake(0.2, 0.08)
			trigger_hitstop(0.04, 0.25)
			return true
		Character.HAND_ACTION_DROP:
			if subject:
				Custom_Logger.debug(self, "Персонаж %s отпускает %s рукой предмет %s" % [character.name, hand_label, subject.name])
			return true

	return false

func ensure_hud() -> void:
	if hud:
		return
	hud = HUD_SCENE.instantiate()
	add_child(hud)
	bind_hud_character()

func on_interactor_ready(new_interactor: Interactor) -> void:
	if hud:
		hud.bind_interactor(new_interactor)


func bind_hud_character() -> void:
	if hud and character and hud.has_method("bind_character"):
		hud.bind_character(character)


func trigger_camera_shake(strength: float, duration: float) -> void:
	if character:
		character.trigger_camera_shake(strength, duration)


func trigger_hitstop(duration: float = 0.06, time_scale: float = 0.2) -> void:
	if character:
		character.trigger_hitstop(duration, time_scale)


func init(ch):
	character = ch
	loco = ch.body
	if character and not character.interactor_ready.is_connected(on_interactor_ready):
		character.interactor_ready.connect(on_interactor_ready)
	ensure_hud()
	bind_hud_character()
	vision_rig = character.ensure_vision_rig()
	vision_camera = character.get_vision_camera()
	if vision_camera:
		vision_camera.current = true
	on_interactor_ready(character.get_interactor())
