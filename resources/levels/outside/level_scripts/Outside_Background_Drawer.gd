extends Node
class_name Outside_Background_Drawer


@onready var upper_drawer = Outside_Upper_Chunk_Drawer.new()
@onready var lower_drawer = Outside_Lower_Chunk_Drawer.new()


func _ready() -> void:
	add_child(upper_drawer)
	add_child(lower_drawer)


func draw_chunk(current_chunk_index: int) -> void:
	Logger.log(self, "start for index: " + str(current_chunk_index))
	
	var upper_chunk_values = Outside_Constants.UPPER_CHUNK.values()
	var upper_chunk_type = upper_chunk_values[randi() % upper_chunk_values.size()]
	
	if upper_chunk_type in [Outside_Constants.UPPER_CHUNK.PARK, Outside_Constants.UPPER_CHUNK.FACTORY]:
		upper_chunk_type = Outside_Constants.UPPER_CHUNK.CROSS_START
	
	Logger.log(self, "picked upper_chunk_type: " + str(upper_chunk_type))
	
	var lower_chunk_values = Outside_Constants.LOWER_CHUNK.values()
	var lower_chunk_type = lower_chunk_values[randi() % lower_chunk_values.size()]
	
	if lower_chunk_type == Outside_Constants.LOWER_CHUNK.PARK:
		lower_chunk_type = Outside_Constants.LOWER_CHUNK.CROSS_START
	
	Logger.log(self, "picked lower_chunk_type: " + str(lower_chunk_type))
	
	upper_drawer.draw_upper_chunk(upper_chunk_type, current_chunk_index, 0)
	lower_drawer.draw_lower_chunk(lower_chunk_type, current_chunk_index, 0)
	
	Logger.log(self, "completed for index: " + str(current_chunk_index))
