extends Node

## Settings - Variables
# Tile Size
const TILE_SIZES = {
	0: 32, # Small
	1: 44, # Medium
	2: 64, # Large
}
var tile_size: int:
	get:
		return tile_size
	set(value):
		value = mini(TILE_SIZES.size(), maxi(value, 0))
		tile_size = value
		for tile in get_tree().get_nodes_in_group("Tiles"):
			tile.set_tile_size()

# Volume
var music_vol: float = 1.0
var sfx_vol: float = 1.0

func _ready() -> void:
	tile_size = 0
