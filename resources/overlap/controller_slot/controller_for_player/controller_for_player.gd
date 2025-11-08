extends Node

var character
var loco
var throw_ability
var melee_ability

func init(ch):
	character = ch
	loco = ch.body
	throw_ability = ch.get_ability("AbilityToThrow")
	melee_ability = ch.get_ability("AbilityToMelee")

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		loco.set_look_delta(event.relative)

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
