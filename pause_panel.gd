extends Panel

@onready var pause_panel: Panel = self
@onready var pause_buttons: VBoxContainer = %PauseButtons
@onready var options: Panel = %Options

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pause_buttons.visible = true
	options.visible = false
	
func resume():
	get_tree().paused = false

func paused():
	get_tree().paused = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var esc_pressed = Input.is_action_just_pressed("pause")
	if esc_pressed:
		get_tree().paused = !get_tree().paused
		pause_panel.visible = !pause_panel.visible
	if options.visible and esc_pressed:
		options.visible = !options.visible
		_ready()
func _on_continue_pressed() -> void:
	resume()
	pause_panel.hide()

func _on_menu_pressed() -> void:
	resume()
	get_tree().change_scene_to_file("res://Scenes/menu/main_menu.tscn")

func _on_options_pressed() -> void:
	pause_buttons.visible = false
	options.visible = true

func _on_back_pressed() -> void:
	_ready()


func _on_close_pressed() -> void:
	get_tree().quit()
