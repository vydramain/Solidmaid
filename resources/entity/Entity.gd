extends CharacterBody2D

signal hp_max_changed(hp)
signal hp_changed(hp)
signal died

@export var hp_max: int = 100 : set = set_hp_max
@export var hp: int = hp_max : set = set_hp
@export var defence: int = 0
@export var invincibility: bool = false

@export var SPEED: int = 50


@onready var collision_shape = $CollisionShape2D

@onready var INVINCIBILITY_TIMER = $InvincibilityTimer


func set_hp_max(new_hp_max: int) -> void:
	if new_hp_max != hp_max:
		var updated_max_hp = max(new_hp_max, 0)
		self.hp = hp * hp_max / updated_max_hp
		hp_max = updated_max_hp
		emit_signal("hp_max_changed", hp_max)

func set_hp(new_hp: int) -> void:
	hp = clamp(new_hp, 0, hp_max)
	emit_signal("hp_changed", hp)
	if hp == 0:
		emit_signal("died")


func _ready() -> void:
	print("[Spawned] Entity '%s': HP = %d / %d, Defence = %d, Speed = %d" % [
		name, hp, hp_max, defence, SPEED
	])

func _on_invincibility_timer_timeout() -> void:
	invincibility = false

func _physics_process(delta: float) -> void:
	move_and_slide()

func _on_hutrbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hitboxes"):
		receive_damage(area.damage)


func receive_damage(base_damage: int) -> void:
	if !invincibility:
		var actual_damage: int = base_damage
		actual_damage -= self.defence
		var new_hp: int = self.hp - actual_damage
		print(self.get_name() + " received " + str(base_damage) + " damge")
		self.set_hp(new_hp) 

func die() -> void:
	queue_free()
