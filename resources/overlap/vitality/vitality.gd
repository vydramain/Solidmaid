extends Node

@export var max_hp: float = 100.0
@export var hp: float = 100.0
@export var invuln_time: float = 0.0

signal damaged(amount, source)
signal died()

func apply_damage(amount: float, source) -> void:
	hp -= amount
	emit_signal("damaged", amount, source)
	if hp <= 0:
		emit_signal("died")
