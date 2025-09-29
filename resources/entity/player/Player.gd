extends "res://resources/entity/Entity.gd"

const home_level_path: String = "res://resources/levels/home/Home_Level.tscn"
const factory_level_path: String = "res://resources/levels/factory/Factory_Level.tscn"
const projecttile_scene_path: String = "res://resources/entity/environment/birck/Brick.tscn"

@onready var home_level: PackedScene = load(home_level_path)
@onready var factiry_level: PackedScene = load(factory_level_path)
@onready var projecttile_scene: PackedScene = preload(projecttile_scene_path)

@onready var sprite = $Sprite2D
@onready var foot_marker = $FootMarker
@onready var character_box = $CharacterBox

@onready var attack_timer = $AttackTimer
@onready var animation_player = $AnimationPlayer

var respawn_position := Vector2(100, 100)
var attack_ready: bool = true

func _ready() -> void:
	Custom_Logger.log(self, "Spawned object. Groups: " + str(self.get_groups()))
	Custom_Logger.log(self, "Node name: %s, AnimationPlayer ready: %s" % [self.name, animation_player])
	
	# Connect timers
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	invincibility_timer.timeout.connect(_on_invincibility_timer_timeout)
	Custom_Logger.log(self, "Timers connected successfully.")

func _on_attack_timer_timeout() -> void:
	attack_ready = true
	Custom_Logger.log(self, "Attack timer ended. Player can attack again.")

func _physics_process(delta: float) -> void:
	var input_dir = get_input_direction()
	
	if input_dir != Vector2.ZERO:
		# Player is moving
		if character_box == null:
			pass
		
		# accelerate toward target
		character_box.velocity = character_box.velocity.move_toward(character_box.speed * input_dir, character_box.accel * delta)
		animation_player.play("Moving")
		animation_player.speed_scale = 2.0
		
		if input_dir.x != 0 and sign(sprite.scale.x) != sign(input_dir.x):
			sprite.scale.x *= -1
			Custom_Logger.log(self, "Sprite flipped. New scale.x: %s" % sprite.scale.x)
	else:
		# Player is idle
		if character_box == null:
			pass
		
		# decelerate toward zero (friction)
		character_box.velocity = character_box.velocity.move_toward(Vector2.ZERO, character_box.friction * delta)
		animation_player.play("Idle")

	# Handle attack input
	if Input.is_action_pressed("action_attack") and attack_ready:
		var attack_dir: Vector2 = Vector2.ZERO
		attack_dir.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
		attack_dir.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
		
		if attack_dir != Vector2.ZERO:
			throw_projecttile(attack_dir)
			Custom_Logger.log(self, "Projectile thrown in direction: %s" % attack_dir)
	
	character_box.move_and_slide()
	character_box.position = Vector2.ZERO  # reset local offset
	global_position += character_box.velocity * delta

func _on_died() -> void:
	var main = get_tree().root.get_node("Main") # Adjust path if needed
	if main == null or not main.has_method("load_level"):
		Custom_Logger.error(self, "[ERROR] Main node with 'load_level' method not found!")
		return
	
	self.die()

func throw_projecttile(direction: Vector2) -> void:
	if projecttile_scene:
		var projecttile_scene = projecttile_scene.instantiate()
		get_tree().current_scene.add_child(projecttile_scene)
		projecttile_scene.global_position = self.global_position
		
		var projectile_rotation = direction.angle()
		projecttile_scene.rotation = projectile_rotation
		
		attack_ready = false
		attack_timer.start()
		Custom_Logger.log(self, "Attack cooldown started.")
		
		invincibility = true
		invincibility_timer.start()
		Custom_Logger.log(self, "Player is temporarily invincible.")

func get_input_direction() -> Vector2:
	var input_dir: Vector2 = Vector2.ZERO
	
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_dir = input_dir.normalized()
	
	return input_dir

func get_bottom_y() -> float:
	return foot_marker.global_position.y
