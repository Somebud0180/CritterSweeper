extends TextureButton

signal tile_pressed
var is_mine: bool = false
var is_revealed: bool = false
var adjacent_mines: int = 0
var tile_size: Vector2 = Vector2(32, 32)

func _ready() -> void:
	texture_normal = texture_normal.duplicate()

func _on_pressed() -> void:
	print("Tile Pressed")
	emit_signal("tile_pressed")

func reveal_tile():
	print("Revealed")
	is_revealed = true
	if is_mine:
		texture_normal.region = Rect2(Vector2(170, 0), tile_size)
	else:
		var x_pos = (adjacent_mines -1) * 34
		texture_normal.region = Rect2(Vector2(x_pos, 34), tile_size)
		if adjacent_mines == 0:
			texture_normal.region = Rect2(Vector2(34, 0), tile_size)
