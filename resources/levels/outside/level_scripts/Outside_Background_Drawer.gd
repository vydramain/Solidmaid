extends Node
class_name Outside_Background_Drawer

@onready var upper_drawer = Outside_Upper_Chunk_Drawer.new()
@onready var lower_drawer = Outside_Lower_Chunk_Drawer.new()

func _ready() -> void:
	add_child(upper_drawer)
	add_child(lower_drawer)
	Logger.log(self, "Outside_Background_Drawer initialized. Upper and lower drawers added to scene tree.")


func draw_chunk(current_chunk_index: int) -> void:
	Logger.log(self, "[Chunk Drawing] Starting chunk generation for index: %d" % current_chunk_index)
	
	# Select upper chunk type
	var upper_chunk_values = Outside_Constants.UPPER_CHUNK.values()
	var upper_chunk_type = upper_chunk_values[randi() % upper_chunk_values.size()]
	
	# Adjust type if needed
	if upper_chunk_type in [Outside_Constants.UPPER_CHUNK.PARK, Outside_Constants.UPPER_CHUNK.FACTORY]:
		Logger.log(self, "[Upper Chunk] %s is not allowed. Switching to CROSS_START." % str(upper_chunk_type))
		upper_chunk_type = Outside_Constants.UPPER_CHUNK.CROSS_START
	
	Logger.log(self, "[Upper Chunk] Selected type: %s" % str(upper_chunk_type))
	
	# Select lower chunk type
	var lower_chunk_values = Outside_Constants.LOWER_CHUNK.values()
	var lower_chunk_type = lower_chunk_values[randi() % lower_chunk_values.size()]
	
	# Adjust type if needed
	if lower_chunk_type == Outside_Constants.LOWER_CHUNK.PARK:
		Logger.log(self, "[Lower Chunk] PARK is not allowed. Switching to CROSS_START.")
		lower_chunk_type = Outside_Constants.LOWER_CHUNK.CROSS_START
	
	Logger.log(self, "[Lower Chunk] Selected type: %s" % str(lower_chunk_type))
	
	# Draw chunks
	Logger.log(self, "[Drawing] Rendering upper chunk at index %d" % current_chunk_index)
	upper_drawer.draw_upper_chunk(upper_chunk_type, current_chunk_index, 0)
	
	Logger.log(self, "[Drawing] Rendering lower chunk at index %d" % current_chunk_index)
	lower_drawer.draw_lower_chunk(lower_chunk_type, current_chunk_index, 0)
	
	Logger.log(self, "[Chunk Drawing] Completed chunk generation for index: %d" % current_chunk_index)
