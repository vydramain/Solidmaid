extends Node

var character
var loco
var throw_ability
var melee_ability
var wants_capture := true

func _ready() -> void:
	if wants_capture:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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
	if Input.is_action_just_pressed("attack"):
		melee_ability.request_start(null)
	if Input.is_action_just_pressed("throw"):
		throw_ability.request_start(null)
	if Input.is_action_just_pressed("interact"):
		character.interactor.interact()


func init(ch):
	character = ch
	loco = ch.body
	throw_ability = ch.get_ability("AbilityToThrow")
	melee_ability = ch.get_ability("AbilityToMelee")
