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
	print("Spawned object in groups: " + str(self.get_groups()))
	print(self.name, " ready, AnimationPlayer: ", ANIMATION_PLAYER)
	
	ATTACK_TIMER.timeout.connect(_on_attack_timer_timeout)
	INVINCIBILITY_TIMER.timeout.connect(_on_invincibility_timer_timeout)

func _on_attack_timer_timeout() -> void:
	attack_ready = true

func _physics_process(delta):
	var input_dir = get_input_direction()
	if input_dir != Vector2.ZERO:
		## PLAYER IS MOVING
		velocity = SPEED * input_dir
		ANIMATION_PLAYER.play("Moving")
		ANIMATION_PLAYER.speed_scale = 2.0
		if input_dir.x != 0 and sign(SPRITE.scale.x) != sign(input_dir.x):
			SPRITE.scale.x *= -1
	else:
		## PLAYER IS IDLE
		velocity = Vector2.ZERO
		ANIMATION_PLAYER.play("Idle")
	
	if Input.is_action_pressed("action_attack") and attack_ready:
		# var direction = self.global_position.direction_to(get_global_mouse_position())
		var attack_dir: Vector2 = Vector2.ZERO
		attack_dir.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
		attack_dir.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
		if attack_dir != Vector2.ZERO:
			throw_projecttile(attack_dir)
	
	move_and_slide()


func _on_died() -> void:
	var main = get_tree().root.get_node("Main") # Adjust path if needed
	if main == null or not main.has_method("load_level"):
		push_error("Main node with 'load_level' method not found in scene tree!")
		return

	var current_level = main.get("current_level")
	var scene_file = current_level.scene_file_path if current_level else ""
	print("Current level: ", scene_file)

	var next_level: PackedScene = null
	if scene_file == HOME_LEVEL_PATH:
		next_level = FACTORY_LEVEL
	elif scene_file == FACTORY_LEVEL_PATH:
		next_level = HOME_LEVEL

	if next_level:
		main.load_level(next_level)
	else:
		push_error("Unable to determine next level from: " + str(scene_file))
		
	self.die()


func throw_projecttile(direction) -> void:
	if PROJECTTILE_SCENE:
		var projecttile_scene = PROJECTTILE_SCENE.instantiate()
		get_tree().current_scene.add_child(projecttile_scene)
		projecttile_scene.global_position = self.global_position
		
		var dagger_rotation = direction.angle()
		projecttile_scene.rotation = dagger_rotation
		
		attack_ready = false
		ATTACK_TIMER.start()
		
		invincibility = true
		INVINCIBILITY_TIMER.start()

func get_input_direction() -> Vector2:
	var input_dir: Vector2 = Vector2.ZERO
	
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_dir = input_dir.normalized()
	
	return input_dir
