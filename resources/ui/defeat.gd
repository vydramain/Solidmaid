extends Node2D

@onready var HOME_LEVEL: PackedScene = preload("res://resources/levels/home/Home_Level.tscn")

func _on_button_pressed():
	get_tree().change_scene_to_packed(HOME_LEVEL)
