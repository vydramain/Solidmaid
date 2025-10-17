extends Node2D

# Throw parameters
@export var floor_y = null
@export var weight: float = 1.0
@export var gravity: float = 980.0
@export var rotation_speed: float = 360.0  # Degrees per second
@export var bounce_damping: float = 0.3  # How much energy is lost on bounce (0.0-1.0)
@export var min_bounce_velocity: float = 50.0  # Minimum velocity to bounce
@export var landing_angle_tolerance: float = 30.0  # Degrees tolerance for landing (±30° from 180°)

# Internal state
var has_landed: bool = false
var is_throwing: bool = false
var is_bouncing: bool = false
var bounce_count: int = 0

# Physics state
var initial_position: Vector2
var initial_velocity: Vector2
var current_velocity: Vector2  # Track current velocity for bouncing
var throw_time: float = 0.0
var initial_rotation: float = 0.0

func _ready():
	if floor_y == null:
		floor_y = global_position.y

func _process(delta: float):
	if not is_throwing or has_landed:
		return
	
	throw_time += delta
	
	# Apply rotation while flying
	rotation_degrees += rotation_speed * delta
	
	# Calculate velocity at current time: v = v0 + g*t
	current_velocity = Vector2(
		initial_velocity.x,
		initial_velocity.y + gravity * throw_time
	)
	
	# x(t) = x0 + vx * t
	# y(t) = y0 + vy * t + 0.5 * g * t²
	var new_position = Vector2(
		initial_position.x + initial_velocity.x * throw_time,
		initial_position.y + initial_velocity.y * throw_time + 0.5 * gravity * throw_time * throw_time
	)
	
	# Check BEFORE applying position
	if new_position.y >= floor_y:
		_handle_ground_contact()
		return
	
	global_position = new_position

func _handle_ground_contact():
	"""Check if brick can land based on rotation"""
	# Normalize rotation to 0-360 range
	var normalized_rotation = fmod(rotation_degrees, 360.0)
	if normalized_rotation < 0:
		normalized_rotation += 360.0
	
	# Check if rotation is near 180° (π radians) - upright position
	var angle_diff = abs(normalized_rotation - 180.0)
	# Also check wrapped around (e.g., 350° is close to 10°, but we want 180°)
	if angle_diff > 180.0:
		angle_diff = 360.0 - angle_diff
	
	var can_land = angle_diff <= landing_angle_tolerance
	
	if can_land:
		# Snap rotation to exactly 180° for clean landing
		rotation_degrees = 180.0
		_bounce()
	else:
		# Wrong angle - force bounce even if velocity is low
		print("Wrong angle: ", normalized_rotation, "° (need ~180°) - forcing bounce")
		_force_bounce()

func _force_bounce():
	"""Force a bounce when landing angle is wrong"""
	# Snap to floor
	global_position = Vector2(global_position.x, floor_y)
	
	bounce_count += 1
	
	# Always give it some vertical velocity to bounce away
	var bounce_velocity = max(abs(current_velocity.y) * bounce_damping, min_bounce_velocity * 1.5)
	
	# Reset for next arc
	initial_position = global_position
	initial_velocity = Vector2(current_velocity.x * 0.8, -bounce_velocity)  # Reduce horizontal velocity too
	throw_time = 0.0
	
	# Keep rotation speed to allow it to rotate to correct angle
	print("Forced bounce #", bounce_count, " - Velocity: ", bounce_velocity)

func _bounce():
	"""Normal bounce when angle is correct"""
	# Snap to floor
	global_position = Vector2(global_position.x, floor_y)
	
	# Check if velocity is too low to bounce
	if abs(current_velocity.y) < min_bounce_velocity:
		_land()
		return
	
	bounce_count += 1
	
	# Reverse vertical velocity and apply damping
	var new_vertical_velocity = -current_velocity.y * bounce_damping
	
	# Reset for next arc with reduced velocity
	initial_position = global_position
	initial_velocity = Vector2(current_velocity.x, new_vertical_velocity)
	throw_time = 0.0
	
	# Reduce rotation speed with each bounce
	rotation_speed *= bounce_damping
	
	print("Bounce #", bounce_count, " - Velocity: ", new_vertical_velocity)

func _land():
	"""Final landing - only happens when angle is correct and velocity is low"""
	global_position = Vector2(global_position.x, floor_y)
	rotation_degrees = 180.0  # Ensure exactly upright
	
	has_landed = true
	is_throwing = false
	
	print("Successfully landed after ", bounce_count, " bounces at position: ", global_position)

func throw(throw_direction: Vector2, throw_strength: float = 300.0):
	if is_throwing:
		return
	
	initial_position = global_position
	initial_velocity = throw_direction.normalized() * throw_strength
	current_velocity = initial_velocity
	initial_rotation = rotation_degrees
	throw_time = 0.0
	bounce_count = 0
	
	is_throwing = true
	has_landed = false

func reset_to_floor():
	global_position = Vector2(global_position.x, floor_y)
	rotation_degrees = 0.0
	is_throwing = false
	has_landed = false
	throw_time = 0.0
	bounce_count = 0
