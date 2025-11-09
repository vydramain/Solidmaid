extends Node2D

@onready var kill_counter_label = get_tree().current_scene.get_node("CanvasLayer/Control/KillCounterLabel")

@export var enemy_scene: PackedScene = preload(Resource_Registry.ENTITY["ENEMY"])

@export var spawn_interval: float = 2.0
@export var spawn_radius: float = 400.0
@export var enemy_killed: int = 0

var spawned_enemies: Array[Node2D] = []
var player: Node2D
var timer := 0.0


func _ready() -> void:
	print("Loaded scene: ", self.name)
	await get_tree().process_frame  # Wait for one frame
	find_player()
	if kill_counter_label != null:
		print("Kill counter text: %s (from node: %s)" % [kill_counter_label.text, kill_counter_label.name])

func _process(delta: float) -> void:
	timer += delta
	if timer >= spawn_interval:
		timer = 0
		#spawn_enemy()

func _on_enemy_freed(node: Node) -> void:
	if node in spawned_enemies:
		spawned_enemies.erase(node)


func find_player() -> void:
	if not player:
		var main = get_tree().root.get_node("Main")
		if main == null:
			print("Main not found")
			return

		var current_level = main.get("current_level")
		if current_level == null:
			print("current_level is null in Main")
			return

		var players = current_level.get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			player = players[0]
			print("Found player: " + str(player))
		else:
			print("No player found in group 'Player'")

func kill_all_enemies() -> void:
	for enemy in spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	spawned_enemies.clear()

func spawn_enemy() -> void:
	if player == null:
		print("Error while spawning enemy: %s: 'player' reference is null; enemy spawner disabled" % self)
		return
	if enemy_scene == null:
		print("Error while spawning enemy: %s: 'enemy_scene' PackedScene is null; did you assign it in the Inspector?" % self)
		return
	
	var enemy: Node2D = enemy_scene.instantiate() as Node2D
	if enemy == null:
		print("Error while spawning enemy: %s.%s: instantiate() returned null — wrong PackedScene or type mismatch?" % [self.get_path(), "spawn_enemy"])
		return
	
	var angle = randf() * TAU
	enemy.global_position = player.global_position + Vector2(cos(angle), sin(angle)) * spawn_radius
	enemy.player = player
	
	print("Current scene is: " + str(get_tree().current_scene))
	get_tree().current_scene.add_child(enemy)
	spawned_enemies.append(enemy)
	
	# Pass spawner reference to enemy
	if enemy is CharacterBody2D and "spawner" in enemy:
		enemy.player = player
		enemy.spawner = self
	else:
		print("Warning: Spawned enemy does not have expected script or 'spawner' property")
	
	get_tree().current_scene.add_child(enemy)
	spawned_enemies.append(enemy)
	
	# Optional: Auto-remove from list when enemy is freed independently
	enemy.connect("tree_exited", Callable(self, "_on_enemy_freed"), CONNECT_ONE_SHOT)

func report_enemy_killed() -> void:
	enemy_killed += 1
	print("Enemy killed. Total: %d" % enemy_killed)
	
	if kill_counter_label:
		kill_counter_label.text = "Score: %d" % enemy_killed
	else:
		print("Kill counter label is not assigned.")
