extends Node2D

@onready var wave_reverse: AnimatedSprite2D = $WaveReverse

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wave_reverse.play("default")
	
	# Zjistíme celkový počet snímků animace
	var frame_count = wave_reverse.sprite_frames.get_frame_count("default")
	
	# Vypočítáme pořadí vlny podle její pozice
	# Tím získáme indexy 1, 2, 3, 4 postupně za sebou
	var wave_index = int(global_position.x / 60.0)
	
	# Nastavíme počáteční snímek na zbytek po dělení, aby to plynule cyklilo zpět na nulu
	wave_reverse.frame = wave_index % frame_count

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
