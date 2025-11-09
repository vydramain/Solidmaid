extends Node

var character
var loco

func init(ch):
	character = ch
	loco = ch.body

func _physics_process(_dt: float) -> void:
	# Placeholder: idle AI (no movement yet)
	pass
