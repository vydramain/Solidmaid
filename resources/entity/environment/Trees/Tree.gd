extends CharacterBody2D

@onready var ANIMATION_PLAYER = $AnimationPlayer

func _ready() -> void:
	ANIMATION_PLAYER.play("Wind")
