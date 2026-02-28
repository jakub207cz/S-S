extends Node2D

@onready var wave_normal: AnimatedSprite2D = $WaveNormal
@onready var wave_reverse: AnimatedSprite2D = $WaveReverse

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wave_normal.play("default")
	wave_reverse.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
