extends TextureButton

signal tile_pressed
var is_mine: bool = false
var is_flagged: bool = false
var is_revealed: bool = false
var adjacent_mines: int = 0
var tile_size: Vector2 = Vector2(32, 32)

func _ready() -> void:
	texture_normal = texture_normal.duplicate()

func reveal_tile():
	is_revealed = true
	if is_mine:
		texture_normal.region = Rect2(Vector2(170, 0), tile_size)
	else:
		var x_pos = (adjacent_mines -1) * 34
		texture_normal.region = Rect2(Vector2(x_pos, 34), tile_size)
		if adjacent_mines == 0:
			texture_normal.region = Rect2(Vector2(34, 0), tile_size)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and !disabled:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if !is_flagged:
					emit_signal("tile_pressed")
			MOUSE_BUTTON_RIGHT:
				if !is_revealed:
					toggle_flagging()

func toggle_flagging():
	is_flagged = !is_flagged
	if is_flagged:
		texture_normal.region = Rect2(Vector2(68,0),tile_size)
	else:
		texture_normal.region = Rect2(Vector2(0,0),tile_size)
