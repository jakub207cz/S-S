extends Node2D

@onready var sub: AnimatedSprite2D = $Sub
@onready var bubbles_1: AnimatedSprite2D = $Sub/Bubbles1
@onready var bubbles_2: AnimatedSprite2D = $Sub/Bubbles2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sub.play("default")
	bubbles_1.play("default")
	bubbles_2.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
