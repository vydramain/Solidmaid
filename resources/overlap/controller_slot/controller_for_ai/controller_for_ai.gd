extends Node

var character
var loco
var look_pivot: Node3D

func init(ch):
	character = ch
	loco = ch.body
	look_pivot = loco.get_look_pivot()

func _physics_process(_dt: float) -> void:
	# Placeholder: idle AI (no movement yet)
	pass
