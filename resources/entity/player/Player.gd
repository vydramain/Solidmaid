extends "res://resources/entity/Entity.gd"

const HOME_LEVEL_PATH: String = "res://resources/levels/home/Home_Level.tscn"
const FACTORY_LEVEL_PATH: String = "res://resources/levels/factory/Factory_Level.tscn"
const PROJECTTILE_SCENE_PATH: String = "res://resources/entity/projecttiles/bircks/Brick.tscn"

@onready var HOME_LEVEL: PackedScene = load(HOME_LEVEL_PATH)
@onready var FACTORY_LEVEL: PackedScene = load(FACTORY_LEVEL_PATH)
@onready var PROJECTTILE_SCENE: PackedScene = preload(PROJECTTILE_SCENE_PATH)

@onready var SPRITE = $Sprite2D
@onready var ATTACK_TIMER = $AttackTimer
@onready var ANIMATION_PLAYER = $AnimationPlayer

var respawn_position := Vector2(100, 100)
var attack_ready: bool = true

func _ready() -> void:
	Custom_Logger.log(self, "Spawned object. Groups: " + str(self.get_groups()))
	Custom_Logger.log(self, "Node name: %s, AnimationPlayer ready: %s" % [self.name, ANIMATION_PLAYER])
	
	# Connect timers
	ATTACK_TIMER.timeout.connect(_on_attack_timer_timeout)
	INVINCIBILITY_TIMER.timeout.connect(_on_invincibility_timer_timeout)
	Custom_Logger.log(self, "Timers connected successfully.")

func _on_attack_timer_timeout() -> void:
	attack_ready = true
	Custom_Logger.log(self, "Attack timer ended. Player can attack again.")

func _physics_process(delta):
	var input_dir = get_input_direction()
	
	if input_dir != Vector2.ZERO:
		# Player is moving
		velocity = SPEED * input_dir
		ANIMATION_PLAYER.play("Moving")
		ANIMATION_PLAYER.speed_scale = 2.0
		
		if input_dir.x != 0 and sign(SPRITE.scale.x) != sign(input_dir.x):
			SPRITE.scale.x *= -1
			Custom_Logger.log(self, "Sprite flipped. New scale.x: %s" % SPRITE.scale.x)
	else:
		# Player is idle
		velocity = Vector2.ZERO
		ANIMATION_PLAYER.play("Idle")

	# Handle attack input
	if Input.is_action_pressed("action_attack") and attack_ready:
		var attack_dir: Vector2 = Vector2.ZERO
		attack_dir.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
		attack_dir.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
		
		if attack_dir != Vector2.ZERO:
			throw_projecttile(attack_dir)
			Custom_Logger.log(self, "Projectile thrown in direction: %s" % attack_dir)
	
	move_and_slide()

func _on_died() -> void:
	var main = get_tree().root.get_node("Main") # Adjust path if needed
	if main == null or not main.has_method("load_level"):
		Custom_Logger.error(self, "[ERROR] Main node with 'load_level' method not found!")
		return
	
	self.die()

func throw_projecttile(direction: Vector2) -> void:
	if PROJECTTILE_SCENE:
		var projecttile_scene = PROJECTTILE_SCENE.instantiate()
		get_tree().current_scene.add_child(projecttile_scene)
		projecttile_scene.global_position = self.global_position
		
		var projectile_rotation = direction.angle()
		projecttile_scene.rotation = projectile_rotation
		
		attack_ready = false
		ATTACK_TIMER.start()
		Custom_Logger.log(self, "Attack cooldown started.")
		
		invincibility = true
		INVINCIBILITY_TIMER.start()
		Custom_Logger.log(self, "Player is temporarily invincible.")

func get_input_direction() -> Vector2:
	var input_dir: Vector2 = Vector2.ZERO
	
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_dir = input_dir.normalized()
	
	return input_dir
