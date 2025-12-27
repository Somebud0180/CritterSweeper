extends GameMode
class_name SeekerMode

# CritterSeeker rules:
# - First click can contain a mine
# - Clicking mines are allowed
# - Win when all mines are revealed
# - Lose when all non-mine tiles are revealed

func should_protect_first_click() -> bool:
	return false

func mine_reveal_is_original_press() -> bool:
	return false

func should_end_on_mine_press() -> bool:
	return false

func is_win_state(tiles: Array) -> bool:
	for row in tiles:
		for tile in row:
			if not tile.is_revealed and tile.is_mine:
				return false
	return true

func is_loss_state(tiles: Array) -> bool:
	for row in tiles:
		for tile in row:
			if not tile.is_revealed and not tile.is_mine:
				return false
	return true

func reveal_tile_on_game_over(tile: TextureButton) -> void:
	tile.reveal_tile(true)
