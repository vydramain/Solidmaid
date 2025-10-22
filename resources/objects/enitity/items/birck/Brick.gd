extends Area2D
class_name Brick

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite_box: Sprite2D = $SpriteBox
@onready var throwable: Node2D = $Throwable
@onready var hurtbox: Area2D = $Hurtbox

# Store floor_y temporarily if set before _ready
var _pending_floor_y: float = -1.0

func _ready() -> void:
	# If floor_y was set before _ready, apply it now
	if _pending_floor_y != -1.0:
		throwable.floor_y = _pending_floor_y
	elif throwable.floor_y == 0.0:
		throwable.floor_y = collision_shape.global_position.y
	
	connect("area_entered", Callable(self, "_on_area_entered"))
	
	if hurtbox:
		hurtbox.monitorable = true
		hurtbox.monitoring = true

func _physics_process(delta: float) -> void:
	if throwable and throwable.is_throwing:
		global_position = throwable.global_position
		rotation = throwable.rotation

func _on_area_entered(area: Area2D) -> void:
	if throwable and throwable.is_throwing:
		if area == null:
			return
		
		var offset: Vector2 = global_position - area.global_position
		var distance: float = offset.length()
		
		var normal: Vector2
		if distance > 0.0001:
			normal = offset / distance
		else:
			var velocity: Vector2 = throwable.current_velocity
			if velocity.length_squared() > 0.0001:
				normal = -velocity.normalized()
			else:
				normal = Vector2.UP
		
		var radius_brick := 0.0
		var brick_shape := collision_shape.shape if collision_shape else null
		if brick_shape is CapsuleShape2D:
			radius_brick = brick_shape.radius
		elif brick_shape is CircleShape2D:
			radius_brick = brick_shape.radius
		
		var radius_other := 0.0
		var other_shape_node: CollisionShape2D = null
		if area.has_node("CollisionShape2D"):
			other_shape_node = area.get_node_or_null("CollisionShape2D")
		if not other_shape_node:
			var candidate_shape = area.get("collision_shape")
			if candidate_shape is CollisionShape2D:
				other_shape_node = candidate_shape
		
		if other_shape_node and other_shape_node.shape:
			var other_shape := other_shape_node.shape
			if other_shape is CapsuleShape2D:
				radius_other = other_shape.radius
			elif other_shape is CircleShape2D:
				radius_other = other_shape.radius
		
		var target_distance := radius_brick + radius_other
		if target_distance > 0 and distance < target_distance:
			var separation := target_distance - distance
			throwable.global_position += normal * separation
		
		throwable.on_impact(normal)
		global_position = throwable.global_position


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
