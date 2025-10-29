extends OptionButton

func _on_item_selected(index: int) -> void:
	Globals.tile_size = index - 1 # Adjust for tile_size starting at -1
