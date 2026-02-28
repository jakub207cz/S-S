extends Node
class_name Inventory

signal inventory_changed(current_count: int, max_capacity: int)

@export var max_capacity: int = 10
var items: Array[ItemData] = []

func add_item(item: ItemData) -> bool:
	if items.size() < max_capacity:
		items.append(item)
		inventory_changed.emit(items.size(), max_capacity)
		GameManager.collected_materials = get_total_value()
		return true
	return false

func clear_inventory() -> void:
	items.clear()
	inventory_changed.emit(items.size(), max_capacity)

func get_total_value() -> int:
	var total: int = 0
	for item in items:
		if item:
			total += item.value
	return total
