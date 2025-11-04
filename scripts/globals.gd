extends Node

## Settings - Variables
# Tile Size
const TILE_SIZES = {
	0: 0, # Fit to screen
	1: 0,  # Fit to screen width
	2: 32, # Small
	3: 44, # Medium
	4: 64, # Large
}

var tile_size: int:
	get:
		return tile_size
	set(value):
		value = mini(TILE_SIZES.keys().max(), maxi(value, 0))
		tile_size = value
		for tile in get_tree().get_nodes_in_group("Tiles"):
			tile.set_tile_size()
		get_tree().get_first_node_in_group("Game").update_tile_sizes()

# Volume
var music_vol: float = 1.0
var sfx_vol: float = 1.0

# Touch Controls
var flag_mode: int: # (Not on KBM) 0 - Hold to Flag; 1 - Flag Mode Sidebar
	get:
		return flag_mode
	set(value):
		value = mini(1, maxi(value, 0))
		flag_mode = value
		get_tree().get_first_node_in_group("MainScreen").update_flag_mode()

# General
var input_type: int: # 0 - KBM; 1 - Touch; 2 - Controller
	get:
		return input_type
	set(value):
		input_type = value
		get_tree().get_first_node_in_group("MainScreen").update_flag_mode() 

func _ready() -> void:
	tile_size = 0
	flag_mode = 1
