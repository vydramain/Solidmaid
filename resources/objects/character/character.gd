extends Node3D

@onready var body := $"Locomotion"
@onready var health := $"Vitality"
@onready var abilities := $"Abilities"
@onready var interactor := $"Interactor"
@onready var controller_slot := $"ControllerSlot"

func _ready():
	health.died.connect(_on_died)
	if controller_slot.controller_scene:
		attach_controller(controller_slot.controller_scene)

func attach_controller(controller_scene: PackedScene):
	controller_slot.get_children().map(func(input_controller): input_controller.queue_free())
	var c = controller_scene.instantiate()
	controller_slot.add_child(c)
	c.init(self)

func get_ability(ability_name: String):
	return abilities.get_node_or_null(ability_name)

func _on_died():
	for a in abilities.get_children():
		if a.has_method("request_stop"):
			a.request_stop()
	controller_slot.process_mode = Node.PROCESS_MODE_DISABLED
