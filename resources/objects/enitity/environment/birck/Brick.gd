extends Area2D
class_name Brick

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite_box: Sprite2D = $SpriteBox
@onready var throwable: Node2D = $Throwable

# Store floor_y temporarily if set before _ready
var _pending_floor_y: float = -1.0

func _ready() -> void:
	# If floor_y was set before _ready, apply it now
	if _pending_floor_y != -1.0:
		throwable.floor_y = _pending_floor_y
	elif throwable.floor_y == 0.0:  # Default value check
		throwable.floor_y = collision_shape.global_position.y

func _physics_process(delta: float) -> void:
	if throwable and throwable.is_throwing:
		global_position = throwable.global_position
		rotation = throwable.rotation

func throw(direction: Vector2, throw_strength: float = 1.0) -> void:
	if throwable:
		throwable.throw(direction, throw_strength)

func setup_floor_y(floor_y: float) -> void:
	# If throwable is already ready, set directly
	if throwable:
		throwable.floor_y = floor_y
	else:
		# Otherwise, store it for later
		_pending_floor_y = floor_y
