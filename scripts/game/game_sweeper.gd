extends GameMode
class_name SweeperMode

# CritterSweeper rules:
# - First click cannot contain mines
# - Clicking a mine = loss
# - Win when all non-mine tiles are revealed

func should_protect_first_click() -> bool:
	return true

func mine_reveal_is_original_press() -> bool:
	return true

func should_end_on_mine_press() -> bool:
	return true

func is_win_state(tiles: Array) -> bool:
	for row in tiles:
		for tile in row:
			if not tile.is_revealed and not tile.is_mine:
				return false
	return true

func is_loss_state(tiles: Array) -> bool:
	return false

func reveal_tile_on_game_over(tile: TextureButton) -> void:
	if tile.is_mine:
		tile.reveal_tile(true)
