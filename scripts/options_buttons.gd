extends VBoxContainer

@onready var resolution_option: OptionButton = $ResolutionOption

const RESOLUTIONS = [
	Vector2i(2560, 1440),
	Vector2i(1920, 1080),
	Vector2i(1366, 768),
	Vector2i(1280, 720),
	Vector2i(1024, 768)
]

func _ready() -> void:
	for res in RESOLUTIONS:
		resolution_option.add_item(str(res.x) + "x" + str(res.y))

	# Try to find current resolution
	var current_res = DisplayServer.window_get_size()
	for i in range(RESOLUTIONS.size()):
		if RESOLUTIONS[i] == current_res:
			resolution_option.select(i)
			break

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if (toggled_on == true):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_v_sync_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_resolution_option_item_selected(index: int) -> void:
	var size = RESOLUTIONS[index]
	DisplayServer.window_set_size(size)
	
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		var screen_id = DisplayServer.window_get_current_screen()
		var screen_rect = DisplayServer.screen_get_usable_rect(screen_id)
		var center_pos = screen_rect.position + (screen_rect.size / 2) - (size / 2)
		DisplayServer.window_set_position(center_pos)


