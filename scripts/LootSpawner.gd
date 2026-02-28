extends Node

@export var scrap_scene: PackedScene = preload("res://scenes/ScrapItem.tscn")

var iron_data = preload("res://scripts/items/ItemIron.gd").new()
var oxygen_data = preload("res://scripts/items/ItemOxygen.gd").new()
var fish_data = preload("res://scripts/items/ItemFish.gd").new()

signal schedule_respawn(item_name: String)

func _ready() -> void:
	iron_data.icon = preload("res://icon.svg")
	oxygen_data.icon = preload("res://icon.svg")
	fish_data.icon = preload("res://icon.svg")
	
	_spawn_fish(30)
	_spawn_iron(40)
	_spawn_oxygen(20)
	
	GameManager.item_collected.connect(_on_item_collected)

func _spawn_item_at_depth(item_data_res: Resource, min_depth_m: float, max_depth_m: float, amount: int = 1) -> void:
	var root_world = get_tree().current_scene
	if not root_world:
		return
		
	var map_node = root_world
	if root_world.has_node("World"):
		map_node = root_world.get_node("World")
	
	for i in range(amount):
		var random_depth = randf_range(min_depth_m, max_depth_m)
		var y_pos = GameManager.PIXELS_PER_METER * random_depth + 300.0
		
		var x_pos = randf_range(300.0, 2100.0) 
		
		var instance = scrap_scene.instantiate()
		instance.position = Vector2(x_pos, y_pos)
		
		instance.item_data = item_data_res
		
		if item_data_res.item_name == "Ryba":
			instance.modulate = Color(0, 0.5, 1.0)
		elif item_data_res.item_name == "Železo":
			instance.modulate = Color(0.6, 0.6, 0.6)
		elif item_data_res.item_name == "Kyslíková bomba":
			instance.modulate = Color(1.0, 0.2, 0.2)
			
		map_node.add_child(instance)

func _spawn_fish(amount: int = 1) -> void:
	_spawn_item_at_depth(fish_data, 10.0, 400.0, amount)

func _spawn_iron(amount: int = 1) -> void:
	_spawn_item_at_depth(iron_data, 400.0, 1000.0, amount)

func _spawn_oxygen(amount: int = 1) -> void:
	_spawn_item_at_depth(oxygen_data, 1000.0, GameManager.MAX_GAME_DEPTH, amount)

func _on_item_collected(item_name: String) -> void:
	var wait_time = 0.0
	if item_name == "Ryba": wait_time = 30.0
	elif item_name == "Železo": wait_time = 45.0
	elif item_name == "Kyslíková bomba": wait_time = 60.0
	else: return
	
	var timer = get_tree().create_timer(wait_time, false)
	timer.timeout.connect(func(): _respawn_specific(item_name))

func _respawn_specific(item_name: String) -> void:
	if item_name == "Ryba":
		_spawn_fish(1)
	elif item_name == "Železo":
		_spawn_iron(1)
	elif item_name == "Kyslíková bomba":
		_spawn_oxygen(1)
