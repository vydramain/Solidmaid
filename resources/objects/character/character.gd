extends Locomotion
class_name Character

signal interactor_ready(interactor)

const HAND_ACTION_NONE := &"none"
const HAND_ACTION_THROW := &"throw"
const HAND_ACTION_PICKUP := &"pickup"
const HAND_ACTION_MELEE := &"melee"
const HAND_ACTION_INTERACT := &"interact"
const HAND_ACTION_DROP := &"drop"
const AFFORDANCE_MELEE := &"melee"
const HAND_MODIFIER_NONE := &"none"
const HAND_MODIFIER_DROP := &"drop"

var body := self
var vision_camera: Camera3D
var hand_animator: HandAnimator

@onready var abilities: Node = $"Abilities"
@onready var health: Vitality = $"Vitality"
@onready var vision_rig: VisionRig = $"VisionRig"
@onready var carry_slots: CarrySlots = $"CarrySlots"
@onready var interactor: Interactor = $"Interactor"
@onready var controller_slot: ControllerSlot = $"ControllerSlot"

var _ability_handlers := {}


func _ready():
	super._ready()
	health.died.connect(on_died)
	if not vision_rig:
		push_error("Character missing VisionRig child node")
	if not carry_slots:
		push_error("Character missing CarrySlots child node")
	if not interactor:
		push_error("Character missing Interactor child node")
	else:
		interactor_ready.emit(interactor)
	update_vision_reference()
	if controller_slot.controller_scene:
		attach_controller(controller_slot.controller_scene)

func on_died():
	for a in abilities.get_children():
		if a.has_method("request_stop"):
			a.request_stop()
	controller_slot.process_mode = Node.PROCESS_MODE_DISABLED

func update_vision_reference():
	if not vision_rig:
		vision_camera = null
		set_look_pivot_node(self)
	else:
		var look_pivot_node := vision_rig.get_node_or_null("LookPivot")
		if look_pivot_node and look_pivot_node is Node3D:
			set_look_pivot_node(look_pivot_node)
		else:
			set_look_pivot_node(self)
		look_pivot_node = look_pivot_node if look_pivot_node is Node3D else null
		vision_camera = look_pivot_node.get_node_or_null("Camera3D") if look_pivot_node else vision_rig.get_node_or_null("LookPivot/Camera3D")
		hand_animator = vision_rig.get_node_or_null("LookPivot/Camera3D/HandAnimator")
	update_camera_current_flag()
	update_carry_slots_aim()
	attach_interactor_to_pivot()

func update_carry_slots_aim():
	if carry_slots:
		carry_slots.attach_to_rig(vision_rig)
		carry_slots.set_aim_node(get_look_pivot())

func update_camera_current_flag() -> void:
	if not vision_camera:
		return
	if controller_slot and controller_slot.controller_kind == 2:
		vision_camera.current = true
	else:
		vision_camera.current = false

func attach_interactor_to_pivot() -> void:
	if interactor == null:
		return
	var pivot := get_look_pivot()
	if pivot == null or interactor.get_parent() == pivot:
		return
	if interactor.get_parent():
		interactor.get_parent().remove_child(interactor)
	pivot.add_child(interactor)
	interactor.transform = Transform3D.IDENTITY


func attach_controller(controller_scene: PackedScene):
	controller_slot.get_children().map(func(input_controller): input_controller.queue_free())
	var c = controller_scene.instantiate()
	controller_slot.add_child(c)
	c.init(self)

func get_ability(ability_name) -> Node:
	if abilities == null:
		return null
	var requested := StringName(ability_name)
	if requested == StringName():
		return null
	for ability_node in abilities.get_children():
		if ability_node == null:
			continue
		if ability_node.has_method("provides") and ability_node.provides(requested):
			return ability_node
		if StringName(ability_node.name) == requested:
			return ability_node
	return null

func get_vision_camera() -> Camera3D:
	return vision_camera

func register_ability_dependency(node: Node) -> void:
	if node is CarrySlots:
		if carry_slots and carry_slots != node:
			Custom_Logger.warning(self, "Character already has CarrySlots, ignoring injected instance")
			return
		carry_slots = node
		update_carry_slots_aim()
	attach_interactor_to_pivot()

func get_carry_slots() -> CarrySlots:
	return carry_slots

func get_vitality() -> Vitality:
	return health

func get_interactor() -> Interactor:
	return interactor

func ensure_vision_rig() -> VisionRig:
	return vision_rig

func pickup_holdable(item: Node3D, preferred_slot: String = "") -> bool:
	if carry_slots == null:
		return false
	return carry_slots.try_pickup(item, preferred_slot)

func request_throw(slot_name: String = "") -> bool:
	if carry_slots == null:
		return false
	return carry_slots.request_throw(slot_name)

func interact_hand(slot_name: StringName, modifier: StringName = HAND_MODIFIER_NONE) -> Dictionary:
	if carry_slots == null or slot_name == StringName():
		return build_hand_action(HAND_ACTION_NONE, null)

	if modifier == HAND_MODIFIER_DROP:
		var dropped := carry_slots.try_drop(String(slot_name))
		if dropped:
			return build_hand_action(HAND_ACTION_DROP, dropped)
		return build_hand_action(HAND_ACTION_NONE, null)

	var slot_key := String(slot_name)
	var held_item := carry_slots.get_item(slot_key)
	if held_item:
		return interact_with_held_item(slot_key, held_item)
	return interact_with_world(slot_key)

func get_interactor_target():
	if interactor:
		return interactor.get_current_target()
	return null

func interact_with_held_item(slot_name: String, held_item: Node3D) -> Dictionary:
	if item_has_affordance(held_item, CarrySlots.AFFORDANCE_THROWABLE):
		var throw_handler: ThrowAbility = get_throw_handler()
		if throw_handler and throw_handler.perform_throw(self, StringName(slot_name)):
			return build_hand_action(HAND_ACTION_THROW, held_item)
	if item_has_affordance(held_item, AFFORDANCE_MELEE):
		var melee_handler: MeleeAbility = get_melee_handler()
		if melee_handler and melee_handler.perform_melee(self, held_item, StringName(slot_name)):
			return build_hand_action(HAND_ACTION_MELEE, held_item)
	return build_hand_action(HAND_ACTION_NONE, held_item)

func interact_with_world(slot_name: String) -> Dictionary:
	var target = get_interactor_target()
	if target == null:
		return build_hand_action(HAND_ACTION_NONE, null)
	if target is Node3D and item_has_affordance(target, CarrySlots.AFFORDANCE_CARRIABLE):
		if pickup_holdable(target, slot_name):
			return build_hand_action(HAND_ACTION_PICKUP, target)
	if target.has_method("interact"):
		target.interact(self)
		return build_hand_action(HAND_ACTION_INTERACT, target)
	if target is Node and (target as Node).is_in_group("interactable"):
		(target as Node).emit_signal.call_deferred("interacted", self)
		return build_hand_action(HAND_ACTION_INTERACT, target)
	return build_hand_action(HAND_ACTION_NONE, target)

func item_has_affordance(item: Node, affordance_name: StringName) -> bool:
	if item == null or affordance_name == StringName():
		return false
	if item.has_method("has_affordance"):
		return item.has_affordance(affordance_name)
	var affordance_root := item.get_node_or_null("Affordances")
	if affordance_root:
		for child in affordance_root.get_children():
			if child is Affordance and child.provides(affordance_name):
				return true
			if child.has_method("provides") and child.provides(affordance_name):
				return true
	return false

func get_throw_handler() -> ThrowAbility:
	return get_ability_handler(&"throw") as ThrowAbility

func get_melee_handler() -> MeleeAbility:
	return get_ability_handler(&"melee") as MeleeAbility

func get_ability_handler(ability_name: StringName) -> Node:
	if _ability_handlers.has(ability_name):
		return _ability_handlers[ability_name]
	var ability_node = get_ability(ability_name)
	if ability_node == null:
		return null
	var ability_scene: PackedScene = ability_node.ability_scene
	if ability_scene == null:
		return null
	var handler_instance: Node = ability_scene.instantiate()
	ability_node.add_child(handler_instance)
	_ability_handlers[ability_name] = handler_instance
	return handler_instance

func build_hand_action(action: StringName, subject: Node) -> Dictionary:
	return {
		"action": action,
		"subject": subject
	}

func trigger_camera_shake(strength: float = 1.0, duration: float = -1.0) -> void:
	if vision_rig and vision_rig.has_method("trigger_micro_shake"):
		vision_rig.trigger_micro_shake(strength, duration)

func trigger_hitstop(duration: float = -1.0, time_scale_override: float = -1.0, shake_strength: float = -1.0) -> void:
	var hitstop: HitstopSystem = get_tree().get_root().get_node_or_null("HITSTOP")
	if hitstop:
		hitstop.trigger(duration, vision_rig, time_scale_override, shake_strength)


func play_hand_animation(anim_name: StringName, slot_name: StringName, perspective: String = "fp", speed: float = 1.0) -> bool:
	if hand_animator:
		return hand_animator.play(anim_name, perspective, speed)
	return false


func get_hand_animator() -> HandAnimator:
	return hand_animator

func refresh_look_pivot():
	if vision_rig:
		var look_pivot_node := vision_rig.get_node_or_null("LookPivot")
		if look_pivot_node and look_pivot_node is Node3D:
			set_look_pivot_node(look_pivot_node)
		else:
			set_look_pivot_node(self)
	else:
		super.refresh_look_pivot()
	update_carry_slots_aim()
