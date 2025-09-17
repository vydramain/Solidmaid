extends CharacterBody2D

signal hp_max_changed(hp)
signal hp_changed(hp)
signal died

@export var SPEED: int = 50

@export var hp_max: int = 100 : set = set_hp_max
@export var hp: int = hp_max : set = set_hp
@export var defence: int = 0
@export var invincibility: bool = false

@onready var collision_shape = $CollisionShape2D
@onready var INVINCIBILITY_TIMER = $InvincibilityTimer

func set_hp_max(new_hp_max: int) -> void:
	if new_hp_max != hp_max:
		var updated_max_hp = max(new_hp_max, 0)
		self.hp = hp * updated_max_hp / hp_max if hp_max != 0 else updated_max_hp
		hp_max = updated_max_hp
		emit_signal("hp_max_changed", hp_max)
		Custom_Logger.log(self, "HP max changed to %d, adjusted current HP to %d" % [hp_max, hp])


func set_hp(new_hp: int) -> void:
	hp = clamp(new_hp, 0, hp_max)
	emit_signal("hp_changed", hp)
	Custom_Logger.log(self, "HP set to %d / %d" % [hp, hp_max])
	if hp == 0:
		emit_signal("died")
		Custom_Logger.log(self, "Entity died")


func _ready() -> void:
	Custom_Logger.log(self, "Spawned Entity '%s': HP = %d / %d, Defence = %d, Speed = %d" % [
		name, hp, hp_max, defence, SPEED
	])


func _on_invincibility_timer_timeout() -> void:
	invincibility = false
	Custom_Logger.log(self, "Invincibility ended")


func _physics_process(delta: float) -> void:
	move_and_slide()


func _on_hutrbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hitboxes"):
		Custom_Logger.log(self, "Entered hitbox from %s with damage %d" % [area.get_name(), area.damage])
		receive_damage(area.damage)


func receive_damage(base_damage: int) -> void:
	if invincibility:
		Custom_Logger.log(self, "Damage ignored due to invincibility: %d" % base_damage)
		return

	var actual_damage: int = max(base_damage - self.defence, 0)
	var new_hp: int = self.hp - actual_damage
	Custom_Logger.log(self, "Received damage: %d (after defence %d), HP will change from %d to %d" % [
		base_damage, self.defence, self.hp, new_hp
	])
	self.set_hp(new_hp)


func die() -> void:
	Custom_Logger.log(self, "Entity queued for removal")
	queue_free()
