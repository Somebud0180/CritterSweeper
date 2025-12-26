extends Node
#### Config code copied over from Prims Maze: https://github.com/Somebud0180/Prism-Maze

### Variables
# App Config
var is_fullscreen: bool:
	set(value):
		is_fullscreen = value
		_save_config()

var window_pos: Vector2i:
	set(value):
		window_pos = value
		_save_config()

var window_size: Vector2i:
	set(value):
		window_size = value
		_save_config()

## Tile Size
const TILE_SIZES = {
	0: 0, # Fit to screen
	1: 0,  # Fit to screen width
	2: 32, # Small
	3: 44, # Medium
	4: 64, # Large
}

var tile_size: int:
	set(value):
		value = mini(TILE_SIZES.keys().max(), maxi(value, 0))
		tile_size = value
		for tile in get_tree().get_nodes_in_group("Tiles"):
			tile.set_tile_size()
		get_tree().get_first_node_in_group("Game").update_tile_sizes()
		_save_config()

## Volume
var music_vol: float:
	set(value):
		music_vol = value
		set_music_vol()
		_save_config()

var sfx_vol: float:
	set(value):
		sfx_vol = value / 2
		set_sfx_vol()
		_save_config()

## Flag Controls
var flag_mode: int: # (Not on KBM) 0 - Hold to Flag; 1 - Flag Mode Sidebar
	set(value):
		value = mini(1, maxi(value, 0))
		flag_mode = value
		get_tree().get_first_node_in_group("MainScreen").update_flag_mode()
		_save_config()

var is_flagging: bool = false

## General
# Background theme management
var available_themes: Array = []
var background_theme: int = 0:
	set(value):
		if available_themes.is_empty():
			_load_available_themes()
		value = mini(available_themes.size() - 1, maxi(value, 0))
		background_theme = value
		_load_background_theme()
		_save_config()

var vibration_enabled: bool:
	set(value):
		vibration_enabled = value
		_save_config()

var input_type: int: ## 0 - KBM; 1 - Touch; 2 - Controller
	set(value):
		input_type = value
		get_tree().get_first_node_in_group("MainScreen").update_flag_mode()
		_save_config()

### Internal Functions
func _ready() -> void:
	_load_config()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_config()
		get_tree().quit()
	elif what == NOTIFICATION_APPLICATION_PAUSED:
		_save_config()

func _load_config() -> void:
	_load_available_themes()
	
	var config = ConfigFile.new()
	
	# Load data from a file.
	var err = config.load("user://settings.cfg")
	
	# If the file didn't load, ignore it.
	if err != OK:
		print("Failed to load config")
		return
	
	# Restore configuration
	if config.get_value("App", "is_fullscreen", false):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	DisplayServer.window_set_position(config.get_value("App", "window_pos", Vector2i(0, 0)))
	DisplayServer.window_set_size(config.get_value("App", "window_size", Vector2i(576, 672)))
	is_fullscreen = config.get_value("App", "is_fullscreen", false)
	tile_size = config.get_value("Setting", "tile_size", 0)
	music_vol = config.get_value("Setting", "music_vol", 0.8)
	sfx_vol = config.get_value("Setting", "sfx_vol", 0.8)
	flag_mode = config.get_value("Setting", "flag_mode", 0)
	vibration_enabled = config.get_value("Setting", "vibration_enabled", true)
	background_theme = config.get_value("Setting", "background_theme", 1)
	
	print(window_pos)
	# Update settings nodes to reflect new value
	_update_settings_nodes()

func _save_config() -> void:
	# Create new ConfigFile object.
	var config = ConfigFile.new()
	
	# Store configuration
	config.set_value("App", "is_fullscreen", DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	config.set_value("App", "window_pos", DisplayServer.window_get_position())
	config.set_value("App", "window_size", DisplayServer.window_get_size())
	config.set_value("Setting", "tile_size", tile_size)
	config.set_value("Setting", "music_vol", music_vol)
	config.set_value("Setting", "sfx_vol", sfx_vol)
	config.set_value("Setting", "flag_mode", flag_mode)
	config.set_value("Setting", "vibration_enabled", vibration_enabled)
	config.set_value("Setting", "background_theme", background_theme)
	
	# Save Config
	config.save("user://settings.cfg")

func _update_settings_nodes() -> void:
	for node in get_tree().get_nodes_in_group("SettingsNode"):
		node.update_value()

## Global Functions
func set_music_vol() -> void:
	for player in get_tree().get_nodes_in_group("MusicPlayer"):
		player.volume_linear = music_vol

func set_sfx_vol() -> void:
	for player in get_tree().get_nodes_in_group("SFXPlayer"):
		player.volume_linear = sfx_vol

func vibrate_stop() -> void:
	if Globals.input_type == 2:
		Input.stop_joy_vibration(0)

func vibrate_hover(duration: float = 0.1) -> void:
	if !vibration_enabled:
		return
	
	if Globals.input_type == 1:
		var dur = int(duration * 1000)
		Input.vibrate_handheld(dur)
	elif Globals.input_type == 2:
		Input.stop_joy_vibration(0)
		Input.start_joy_vibration(0, 0.15, 0.0, duration)

func vibrate_light_press(duration: float = 0.1) -> void:
	if !vibration_enabled:
		return
	
	if Globals.input_type == 1:
		var dur = int(duration * 1000)
		Input.vibrate_handheld(dur, 0.01)
	elif Globals.input_type == 2:
		Input.stop_joy_vibration(0)
		Input.start_joy_vibration(0, 0.2, 0.0, duration)

func vibrate_hard_press(duration: float = 0.1) -> void:
	if !vibration_enabled:
		return
	
	if Globals.input_type == 1:
		var dur = int(duration * 1000)
		Input.vibrate_handheld(dur, 0.05)
	elif Globals.input_type == 2:
		Input.stop_joy_vibration(0)
		Input.start_joy_vibration(0, 0.0, 0.3, duration)

## Background Theme Functions
func _load_available_themes() -> void:
	available_themes.clear()
	var themes_dir = DirAccess.open("res://assets/game/sprites/themes")
	if themes_dir == null:
		push_error("Cannot open themes folder: res://assets/game/sprites/themes")
		return
	
	themes_dir.list_dir_begin()
	var folder_name = themes_dir.get_next()
	while folder_name != "":
		if themes_dir.current_is_dir() and not folder_name.begins_with("."):
			available_themes.append(folder_name)
		folder_name = themes_dir.get_next()
	themes_dir.list_dir_end()
	
	available_themes.sort()
	if available_themes.is_empty():
		push_warning("No themes found in res://assets/game/sprites/themes")

func get_available_themes() -> Array:
	if available_themes.is_empty():
		_load_available_themes()
	return available_themes

func get_current_theme_name() -> String:
	if available_themes.is_empty():
		_load_available_themes()
	if background_theme < available_themes.size():
		return available_themes[background_theme]
	return ""

func _load_background_theme() -> void:
	# Notify any listeners (like BackgroundLayer) to update their textures
	var background_layer = get_tree().get_first_node_in_group("BackgroundLayer")
	if background_layer and background_layer.has_method("reload_theme"):
		background_layer.reload_theme()
