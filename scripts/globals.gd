extends Node

## Settings - Variables
# Tile Size
const TILE_SIZES = {
	-1: 0, # Fit to screen
	0: 0,  # Fit to screen width
	1: 32, # Small
	2: 44, # Medium
	3: 64, # Large
}
var tile_size: int:
	get:
		return tile_size
	set(value):
		value = mini(TILE_SIZES.keys().max(), maxi(value, -1))
		tile_size = value
		for tile in get_tree().get_nodes_in_group("Tiles"):
			tile.set_tile_size()
		get_tree().get_first_node_in_group("Game").update_tile_sizes()

# Volume
var music_vol: float = 1.0
var sfx_vol: float = 1.0

func _ready() -> void:
	tile_size = -1
