extends Entity

var player = null
var spawner: Node  # Set by spawner when instantiating

@onready var physic_box: RigidBody2D = $PhysicBox
@onready var physic_line: StaticBody2D = $PhysicLine

@onready var floor_coord_y = null

func _ready() -> void:
	add_to_group("enemies")
	
	# Log spawning using Logger
	Custom_Logger.log(self, "[Spawned] Name: %s | Position: %s" % [name, global_position])
	
	if floor_coord_y == null:
		floor_coord_y = physic_line.global_position.y

func _physics_process(delta: float) -> void:
	# Sync Enemy to PhysicBox
	global_position = physic_box.global_position
	
	physic_box.linear_velocity = physic_box.linear_velocity.move_toward(Vector2.ZERO, physic_box.friction * delta)
	
	# Keep PhysicLine vertical and synced
	if floor_coord_y != null:
		physic_line.global_position.y = floor_coord_y

func _on_died() -> void:
	if spawner:
		spawner.report_enemy_killed()
		Custom_Logger.log(self, "[Died] Reported to spawner.")
	else:
		Custom_Logger.log(self, "[Died] No spawner assigned.")
	
	self.die()
	Custom_Logger.log(self, "[Removed] Enemy has been removed from the scene.")
