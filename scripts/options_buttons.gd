extends VBoxContainer

@onready var resolution_option: OptionButton = $ResolutionOption
@onready var fullscreen_checkbox: CheckBox = $Fullscreen
@onready var vsync_checkbox: CheckBox = $VSync

func _ready() -> void:
	# Načíst stav UI ze SettingsManageru místo z výchozích hodnot scény
	fullscreen_checkbox.button_pressed = SettingsManager.fullscreen
	vsync_checkbox.button_pressed = SettingsManager.vsync
	
	# Vybrat správné rozlišení v dropdownu podle textu definovaného v Editoru (Items)
	var current_res = SettingsManager.resolution
	var res_string = str(current_res.x) + "x" + str(current_res.y)
	
	for i in range(resolution_option.item_count):
		if resolution_option.get_item_text(i) == res_string:
			resolution_option.select(i)
			break

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	SettingsManager.fullscreen = toggled_on
	SettingsManager.apply_settings()
	SettingsManager.save_settings()

func _on_v_sync_toggled(toggled_on: bool) -> void:
	SettingsManager.vsync = toggled_on
	SettingsManager.apply_settings()
	SettingsManager.save_settings()

func _on_resolution_option_item_selected(index: int) -> void:
	var text = resolution_option.get_item_text(index)
	var parts = text.split("x")
	
	if parts.size() == 2:
		var size = Vector2i(parts[0].to_int(), parts[1].to_int())
		SettingsManager.resolution = size
		print("Selected resolution: ", size)
		
		# Pokud jsme ve windowed módu, rovnou aplikujeme, jinak to bude vidět po vypnutí fullscreenu
		if not SettingsManager.fullscreen:
			SettingsManager.apply_settings()
			
		SettingsManager.save_settings()
