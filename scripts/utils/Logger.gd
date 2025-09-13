extends Node
class_name Logger

enum LogLevel {
	DEBUG,
	INFO,
	WARNING,
	ERROR
}

# Rate limiting settings
static var max_logs_per_second: int = 60
static var max_duplicate_logs: int = 3
static var log_count: int = 0
static var last_second: int = 0
static var duplicate_tracker: Dictionary = {}
static var current_log_level: LogLevel = LogLevel.DEBUG

# Color formatting for different log levels
static var log_colors: Dictionary = {
	LogLevel.DEBUG: "white",
	LogLevel.INFO: "cyan", 
	LogLevel.WARNING: "yellow",
	LogLevel.ERROR: "red"
}

static var log_prefixes: Dictionary = {
	LogLevel.DEBUG: "[DEBUG]",
	LogLevel.INFO: "[INFO]",
	LogLevel.WARNING: "[WARN]",
	LogLevel.ERROR: "[ERROR]"
}

# Main logging function with rate limiting
static func log(caller: Object, msg: String, level: LogLevel = LogLevel.INFO) -> void:
	# Skip logs below current level
	if level < current_log_level:
		return
	
	# Rate limiting check
	if not _should_log():
		return
	
	# Duplicate detection
	var log_key = _get_caller_key(caller) + msg
	if _is_duplicate_spam(log_key):
		return
	
	var formatted_message = _format_message(caller, msg, level)
	
	# Use print_rich for colored output in Godot 4
	if level >= LogLevel.WARNING:
		print_rich("[color=%s]%s[/color]" % [log_colors[level], formatted_message])
	else:
		print(formatted_message)

# Convenience methods for different log levels - FIXED
static func debug(caller: Object, msg: String) -> void:
	Logger.log(caller, msg, LogLevel.DEBUG)

static func info(caller: Object, msg: String) -> void:
	Logger.log(caller, msg, LogLevel.INFO)

static func warning(caller: Object, msg: String) -> void:
	Logger.log(caller, msg, LogLevel.WARNING)

static func error(caller: Object, msg: String) -> void:
	Logger.log(caller, msg, LogLevel.ERROR)

# Set minimum log level (useful for release builds)
static func set_log_level(level: LogLevel) -> void:
	current_log_level = level

# Rate limiting logic
static func _should_log() -> bool:
	var current_second = Time.get_unix_time_from_system() as int
	
	# Reset counter every second
	if current_second != last_second:
		log_count = 0
		last_second = current_second
		# Clean old duplicate entries every 10 seconds
		if current_second % 10 == 0:
			_clean_duplicate_tracker()
	
	# Check if we've hit the rate limit
	if log_count >= max_logs_per_second:
		# Print overflow warning once per second
		if log_count == max_logs_per_second:
			print_rich("[color=red][LOGGER] Rate limit exceeded (%d logs/sec). Suppressing further logs this second.[/color]" % max_logs_per_second)
		log_count += 1
		return false
	
	log_count += 1
	return true

# Check for duplicate spam
static func _is_duplicate_spam(log_key: String) -> bool:
	var current_time = Time.get_unix_time_from_system() as int
	
	if not duplicate_tracker.has(log_key):
		duplicate_tracker[log_key] = {"count": 1, "last_time": current_time}
		return false
	
	var entry = duplicate_tracker[log_key]
	
	# Reset count if it's been more than 5 seconds
	if current_time - entry.last_time > 5:
		entry.count = 1
		entry.last_time = current_time
		return false
	
	entry.count += 1
	entry.last_time = current_time
	
	# Allow first few duplicates, then start suppressing
	if entry.count > max_duplicate_logs:
		if entry.count == max_duplicate_logs + 1:
			print_rich("[color=orange][LOGGER] Suppressing duplicate log: %s[/color]" % log_key.substr(0, 50))
		return true
	
	return false

# Clean old entries from duplicate tracker
static func _clean_duplicate_tracker() -> void:
	var current_time = Time.get_unix_time_from_system() as int
	var keys_to_remove = []
	
	for key in duplicate_tracker.keys():
		if current_time - duplicate_tracker[key].last_time > 30:
			keys_to_remove.append(key)
	
	for key in keys_to_remove:
		duplicate_tracker.erase(key)

# Generate a unique key for the caller
static func _get_caller_key(caller: Object) -> String:
	if not caller:
		return "[NO_CALLER]"
	
	if caller.has_method("get_path"):
		return str(caller.get_path())
	elif caller.has_method("get_script") and caller.get_script():
		var script_name = caller.get_script().get_global_name()
		if script_name.is_empty():
			script_name = str(caller.get_class())
		return script_name
	else:
		return str(caller.get_class())

# Format the complete log message
static func _format_message(caller: Object, msg: String, level: LogLevel) -> String:
	if not caller:
		return "%s [NO_CALLER] %s" % [log_prefixes[level], msg]
	
	var scene_name = "NO_CURRENT_SCENE"
	var place = "NO_PATH"
	
	# Check if caller has access to scene tree (is a Node)
	if caller.has_method("get_tree") and caller.get_tree() and caller.get_tree().current_scene:
		scene_name = caller.get_tree().current_scene.name
	
	if caller.has_method("get_path"):
		place = str(caller.get_path())
	elif caller.has_method("get_script") and caller.get_script():
		# For RefCounted objects, show the class name instead
		place = caller.get_script().get_global_name()
		if place.is_empty():
			place = str(caller.get_class())
	
	return "%s [{scene} | {place}] {msg}".format({
		"scene": scene_name,
		"place": place,
		"msg": msg
	}) % log_prefixes[level]

# Utility function to log with automatic caller detection (GDScript 4+ only)
static func auto_log(msg: String, level: LogLevel = LogLevel.INFO) -> void:
	var stack = get_stack()
	var caller_info = "UNKNOWN"
	if stack.size() > 1:
		caller_info = "%s:%d" % [stack[1].source, stack[1].line]
	
	var formatted_msg = "%s [AUTO:%s] %s" % [log_prefixes[level], caller_info, msg]
	
	if level >= LogLevel.WARNING:
		print_rich("[color=%s]%s[/color]" % [log_colors[level], formatted_msg])
	else:
		print(formatted_msg)
