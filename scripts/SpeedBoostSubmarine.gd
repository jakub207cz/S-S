extends StaticBody2D
class_name TraderSubmarine

var required_items: Dictionary = {}
var trades_completed: int = 0

var floating_ui_scene: PackedScene = preload("res://scenes/ui/FloatingInventoryUI.tscn")
var floating_ui_instance: Control
var reset_timer: Timer

@onready var sprite: AnimatedSprite2D = $Sprite2D

func _ready() -> void:
	# Vygenerování random 1, 2 nebo 3 položek pro trade
	_generate_requirements()
	
	# Vytvoření vizuálního elementu
	floating_ui_instance = floating_ui_scene.instantiate()
	add_child(floating_ui_instance)
	floating_ui_instance.position = Vector2(0, -80) # Posun nad vrak
	
	floating_ui_instance.update_inventory(required_items)
	
	input_event.connect(_on_input_event)
	
	# Začátek časovače pro automatickou obnovu tradů: 2 minuty PO splnění
	reset_timer = Timer.new()
	reset_timer.wait_time = 120.0
	reset_timer.autostart = false
	reset_timer.one_shot = true
	reset_timer.timeout.connect(_reset_trade)
	add_child(reset_timer)
	
	# Výchozí stav
	_update_visuals()

func _update_visuals() -> void:
	# Vždy vrtulkou k levé stěně (čelem doprava)
	sprite.flip_h = false
	
	if trades_completed == 0:
		sprite.play("wrecked_static")
		sprite.modulate = Color(0.56, 0.77, 0.9, 1)
	elif trades_completed == 1:
		# První trade: začne se hýbat, ale stále zrezivělá
		sprite.play("wrecked_moving")
		sprite.modulate = Color(0.56, 0.77, 0.9, 1)
	elif trades_completed >= 2:
		# Druhý trade: opravená, používá submarine_4
		sprite.play("repaired_final")
		sprite.modulate = Color.WHITE

func _reset_trade() -> void:
	# Vyčistit starý úkol a vygenerovat nový
	required_items.clear()
	_generate_requirements()
	floating_ui_instance.update_inventory(required_items)
	
	# Zajistit že po předchozím úspěšném obchodu bude možné okno opět prokliknout
	if not input_event.is_connected(_on_input_event):
		input_event.connect(_on_input_event)
	
	print("Nový trade je k dispozici!")

func _generate_requirements() -> void:
	# Máme přístup k datovým typům z LootSpawneru (nebo je načteme napřímo)
	var iron_data = preload("res://scripts/items/ItemIron.gd").new()
	var oxygen_data = preload("res://scripts/items/ItemOxygen.gd").new()
	var fish_data = preload("res://scripts/items/ItemFish.gd").new()
	
	iron_data.icon = preload("res://icon.svg")
	oxygen_data.icon = preload("res://icon.svg")
	fish_data.icon = preload("res://icon.svg")
	
	var possible_items = [iron_data, fish_data, oxygen_data]
	
	var num_requirements = randi() % 3 + 1 # 1 až 3 druhy surovin
	
	for i in range(num_requirements):
		# Vybereme náhodný druh
		var random_item = possible_items[randi() % possible_items.size()]
		var random_amount = randi() % 5 + 1 # Náhodné množství od 1 do 5
		
		# Pokud bychom zvolili stejný item jako v předchozí iteraci, 
		# jednoduše se množství jen sečte díky klíčům
		if required_items.has(random_item):
			required_items[random_item] += random_amount
		else:
			required_items[random_item] = random_amount

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_attempt_trade()

func _attempt_trade() -> void:
	# 1. Zjistit jestli má hráč dané suroviny bezpečně
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty(): return
	
	var player: Submarine = players[0]
	var player_inv: Inventory = player.inventory
	
	# 2. Kontrola, zde ho má dostatek
	var has_all = true
	for req_item in required_items.keys():
		var amount_needed = required_items[req_item]
		var matched = false
		for player_item in player_inv.items.keys():
			# Jelikož porovnáváme instance ItemData, musíme kontrolovat jméno
			if player_item.item_name == req_item.item_name and player_inv.items[player_item] >= amount_needed:
				matched = true
				break
		if not matched:
			has_all = false
			break
			
	# 3. Pokud má dostatek - sebereme a dáme mu reward
	if has_all:
		for req_item in required_items.keys():
			var amount_needed = required_items[req_item]
			# Najdeme znovu ten správný klíč ze slovníku hráče pro vymazání
			var key_to_remove = null
			for player_item in player_inv.items.keys():
				if player_item.item_name == req_item.item_name:
					key_to_remove = player_item
					break
			if key_to_remove:
				player_inv.remove_item(key_to_remove, amount_needed)
				
		_give_reward()
		
		# Zvýšíme počet splněných tradů
		trades_completed += 1
		_update_visuals()
		
		# Zmizení ikonek (trade splněn)
		required_items.clear()
		floating_ui_instance.update_inventory(required_items)
		
		# Deaktivace klikání
		if input_event.is_connected(_on_input_event):
			input_event.disconnect(_on_input_event)
			
		# Spustíme odpočet na další trade (2 minuty), ALE JEN POKUD NENÍ HOTOVO
		if trades_completed < 2:
			reset_timer.start()
			print("Trade splněn! Další za 2 minuty.")
		else:
			# Po 2. tradu je konec, schováme UI
			floating_ui_instance.visible = false
			print("Ponorka byla plně opravena a už nic nepotřebuje.")
	else:
		print("Nemáš dostatek surovin na trade!")

func _give_reward() -> void:
	# Jednoduchý systém - náhodná odměna
	var reward_type = randi() % 3
	match reward_type:
		0:
			print("Trade accepted: +Speed")
			GameManager.apply_speed_boost(GameManager.get_speed_multiplier() + 0.5)
		1:
			print("Trade accepted: +Damage/HP")
			GameManager.engine_level += 1
		2:
			print("Trade accepted: +Inventory Space")
			var players = get_tree().get_nodes_in_group("player")
			if not players.is_empty():
				var player: Submarine = players[0]
				player.inventory.max_capacity += 10
				player.inventory.inventory_changed.emit(player.inventory.get_total_count(), player.inventory.max_capacity)
