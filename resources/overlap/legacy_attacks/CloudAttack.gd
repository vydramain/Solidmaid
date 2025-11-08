extends Node2D

@onready var sprite_box: Sprite2D = $CloudSmoke/SpriteBox
@onready var animation_player: AnimationPlayer = $CloudSmoke/SpriteBox/AnimationPlayer

@onready var hurtbox_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var hitbox: Area2D = $Hitbox

@onready var attack_timer: Timer = $AttackTimer

const DEFAULT_COLLISION = { "x": 24.0, "y": -2.0, "rot": 90.0, "radius": .0, "height": .0 }

# Frame collision data
const FRAME_COLLISION = {
	0: { "x": 24.0, "y": -2.0, "rot": 90.0, "radius": 4.0, "height": 14.0 },
	1: { "x": 14.0, "y": -5.0, "rot": 90.0, "radius": 11.0, "height": 36.0 },
	2: { "x": 1.0,  "y": 1.0,  "rot": 90.0, "radius": 17.0, "height": 58.0 },
	3: { "x": 1.0,  "y": 1.0,  "rot": 90.0, "radius": 17.0, "height": 58.0 },
}

var _attack_ability: bool = true

func _ready() -> void:
	attack_timer.autostart = false
	attack_timer.wait_time = 3.
	
	attack()

func _set_hurtbox(data: Dictionary) -> void:
	var shape := hurtbox_shape.shape
	if shape is CapsuleShape2D:
		shape.radius = data["radius"]
		shape.height = data["height"]
	
	hurtbox_shape.position = Vector2(data["x"], data["y"])
	hurtbox_shape.rotation_degrees = data["rot"]

func _on_sprite_box_frame_changed() -> void:
	if not animation_player.get_current_animation() == "Smoke":
		return
	
	if FRAME_COLLISION.has(sprite_box.frame):
		var data = FRAME_COLLISION[sprite_box.frame]
		hurtbox_shape.disabled = false
		_set_hurtbox(data)
	else:
		hurtbox_shape.disabled = true
		_set_hurtbox(DEFAULT_COLLISION)

func _on_attack_timer_timeout() -> void:
	_attack_ability = true
	attack()


func attack() -> void:
	if _attack_ability:
		_attack_ability = false
		animation_player.play("Smoke")
		attack_timer.start()

func resetAttackTimer() -> void:
	pass
