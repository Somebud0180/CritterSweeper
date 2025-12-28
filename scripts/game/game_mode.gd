extends Resource
class_name GameMode

# Base class for game mode behavior
# Override these methods in subclasses to define mode-specific rules

func should_protect_first_click() -> bool:
	return false

func mine_reveal_is_original_press() -> bool:
	return false

func should_end_on_mine_press() -> bool:
	return false

@warning_ignore("unused_parameter")
func is_win_state(tiles: Array) -> bool:
	return false

@warning_ignore("unused_parameter")
func is_loss_state(tiles: Array) -> bool:
	return false

func reveal_tile_on_game_over(tile: TextureButton) -> void:
	if tile.is_mine:
		tile.reveal_tile(true)
