extends Node
#### Config code copied over from Prims Maze: https://github.com/Somebud0180/Prism-Maze

### Variables
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
		_save_config()

var sfx_vol: float:
	set(value):
		sfx_vol = value
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
var vibration: bool:
	set(value):
		vibration = value
		_save_config()

var input_type: int: # 0 - KBM; 1 - Touch; 2 - Controller
	set(value):
		input_type = value
		get_tree().get_first_node_in_group("MainScreen").update_flag_mode()
		_save_config()

### Internal Functions
func _ready() -> void:
	_load_config()

func _load_config() -> void:
	var config = ConfigFile.new()
	print(config)
	
	# Load data from a file.
	var err = config.load("user://settings.cfg")
	
	# If the file didn't load, ignore it.
	if err != OK:
		print("Failed to load config")
		return
	
	# Restore configuration
	tile_size = config.get_value("Setting", "tile_size", 0)
	music_vol = config.get_value("Setting", "music_vol", 0.8)
	sfx_vol = config.get_value("Setting", "sfx_vol", 0.8)
	flag_mode = config.get_value("Setting", "flag_mode", 0)
	vibration = config.get_value("Setting", "vibration", true)
	
	# Update settings nodes to reflect new value
	_update_settings_nodes()

func _save_config() -> void:
	print("Saving config")
	
	# Create new ConfigFile object.
	var config = ConfigFile.new()
	
	# Store configuration
	config.set_value("Setting", "tile_size", tile_size)
	config.set_value("Setting", "music_vol", music_vol)
	config.set_value("Setting", "sfx_vol", sfx_vol)
	config.set_value("Setting", "flag_mode", flag_mode)
	config.set_value("Setting", "vibration", vibration)
	
	# Save Config
	config.save("user://settings.cfg")

func _update_settings_nodes() -> void:
	for node in get_tree().get_nodes_in_group("SettingsNode"):
		node.update_value()

## Global Functions
func set_sfx_vol() -> void:
	for player in get_tree().get_nodes_in_group("SFXPlayer"):
		player.volume_linear = sfx_vol

func vibrate_stop() -> void:
	if Globals.input_type == 2:
		Input.stop_joy_vibration(0)

func vibrate_hover(duration: float = 0.1) -> void:
	if !vibration:
		return
	
	if Globals.input_type == 1:
		var dur = int(duration * 1000)
		Input.vibrate_handheld(dur)
	elif Globals.input_type == 2:
		Input.stop_joy_vibration(0)
		Input.start_joy_vibration(0, 0.15, 0.0, duration)

func vibrate_light_press(duration: float = 0.1) -> void:
	if !vibration:
		return
	
	if Globals.input_type == 1:
		var dur = int(duration * 1000)
		Input.vibrate_handheld(dur)
	elif Globals.input_type == 2:
		Input.stop_joy_vibration(0)
		Input.start_joy_vibration(0, 0.2, 0.0, duration)

func vibrate_hard_press(duration: float = 0.1) -> void:
	if !vibration:
		return
	
	if Globals.input_type == 1:
		var dur = int(duration * 1000)
		Input.vibrate_handheld(dur)
	elif Globals.input_type == 2:
		Input.stop_joy_vibration(0)
		Input.start_joy_vibration(0, 0.0, 0.3, duration)
