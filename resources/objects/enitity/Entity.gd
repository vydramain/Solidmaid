extends Area2D
class_name Entity

signal hp_max_changed(hp)
signal hp_changed(hp)
signal died

@export var hp_max: int = 100 : set = set_hp_max
@export var hp: int = hp_max : set = set_hp
@export var defence: int = 0
@export var invincibility: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var foot_marker = $FootMarker
@onready var invincibility_timer: Timer = $InvincibilityTimer


func _process(_delta: float) -> void:
	z_index = int(foot_marker.global_position.y)

func _on_invincibility_timer_timeout() -> void:
	invincibility = false

func _on_died() -> void:
	die()


func set_hp_max(new_hp_max: int) -> void:
	if new_hp_max != hp_max:
		var updated_max_hp = max(new_hp_max, 0)
		self.hp = hp * updated_max_hp / hp_max if hp_max != 0 else updated_max_hp
		hp_max = updated_max_hp
		emit_signal("hp_max_changed", hp_max)

func set_hp(new_hp: int) -> void:
	hp = clamp(new_hp, 0, hp_max)
	emit_signal("hp_changed", hp)
	if hp <= 0:
		emit_signal("died")

func receive_damage(base_damage: int) -> void:
	if invincibility:
		return
	
	var actual_damage: int = max(base_damage - self.defence, 0)
	var new_hp: int = self.hp - actual_damage
	self.set_hp(new_hp)

func die() -> void:
	queue_free()
