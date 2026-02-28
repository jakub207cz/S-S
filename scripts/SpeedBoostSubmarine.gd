extends Area2D
class_name SpeedBoostSubmarine

@export var multiplier_value: float = 3.0

func _ready() -> void:
	# Použijeme signál input_event pro detekci kliknutí na Area2D
	input_event.connect(_on_input_event)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Kliknuto na speed boost s násobitelem: ", multiplier_value)
		GameManager.apply_speed_boost(multiplier_value)
		# Objekt zůstane, nezničíme ho (jak si uživatel přál)
