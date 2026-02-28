extends VBoxContainer

@onready var resolution_option: OptionButton = $ResolutionOption
@onready var fullscreen_checkbox: CheckBox = $Fullscreen
@onready var vsync_checkbox: CheckBox = $VSync

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

	# Načíst stav UI ze SettingsManageru místo z výchozích hodnot scény
	fullscreen_checkbox.button_pressed = SettingsManager.fullscreen
	vsync_checkbox.button_pressed = SettingsManager.vsync
	
	# Vybrat správné rozlišení v dropdownu
	var current_res = SettingsManager.resolution
	for i in range(RESOLUTIONS.size()):
		if RESOLUTIONS[i] == current_res:
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
	var size = RESOLUTIONS[index]
	SettingsManager.resolution = size
	
	# Pokud jsme ve windowed módu, rovnou aplikujeme, jinak to bude vidět po vypnutí fullscreenu
	if not SettingsManager.fullscreen:
		SettingsManager.apply_settings()
		
	SettingsManager.save_settings()
