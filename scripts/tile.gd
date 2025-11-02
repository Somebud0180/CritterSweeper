extends TextureButton

signal tile_pressed
var is_mine: bool = false
var is_flagged: bool = false
var is_revealed: bool = false
var adjacent_mines: int = 0
var tile_size: Vector2 = Vector2(32, 32)
var touch_held: bool = false
var long_press_triggered: bool = false

func _ready() -> void:
	texture_normal = texture_normal.duplicate()
	set_tile_size()

func set_tile_size(custom_size: float = 0) -> void:
	if custom_size != 0:
		# Size specified by game.gd for dynamic sizing
		custom_minimum_size = Vector2(custom_size, custom_size)
		pivot_offset = Vector2(custom_size/2, custom_size/2)
	else:
		var tile_size_setting = Globals.tile_size
		# Don't set a size when using dynamic sizing (-1, 0)
		if tile_size_setting <= 0:
			return
		else:
			# Use predefined tile size
			var custom_tile_size = Globals.TILE_SIZES[tile_size_setting]
			custom_minimum_size = Vector2(custom_tile_size, custom_tile_size)
			pivot_offset = Vector2(custom_tile_size/2, custom_tile_size/2)

func reveal_tile(original_press: bool = false):
	if is_revealed:
		return
	
	is_revealed = true
	if is_mine:
		print(original_press)
		texture_normal.region = Rect2(Vector2(204, 0), tile_size) if original_press else Rect2(Vector2(170, 0), tile_size)
	else:
		var x_pos = (adjacent_mines -1) * 34
		texture_normal.region = Rect2(Vector2(x_pos, 34), tile_size)
		if adjacent_mines == 0:
			texture_normal.region = Rect2(Vector2(34, 0), tile_size)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and !disabled:
		if event.pressed:
			# Touch started - begin long press timer
			touch_held = true
			long_press_triggered = false
			$Timer.start()
		else:
			# Touch released
			$Timer.stop()
			if touch_held and !long_press_triggered:
				# Short tap - reveal tile
				if !is_flagged:
					emit_signal("tile_pressed")
			touch_held = false
			long_press_triggered = false
		accept_event()
		return

	elif event is InputEventMouseButton and event.is_pressed() and !disabled:
		if event.device == -1:
			accept_event()
			return
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if !is_flagged:
					emit_signal("tile_pressed")
			MOUSE_BUTTON_RIGHT:
				if !is_revealed:
					toggle_flagging()

func _on_timer_timeout() -> void:
	# Timer expired while still holding - flag the tile
	if touch_held and !is_revealed and !disabled:
		long_press_triggered = true
		toggle_flagging()

func toggle_flagging():
	is_flagged = !is_flagged
	if is_flagged:
		texture_normal.region = Rect2(Vector2(68,0),tile_size)
	else:
		texture_normal.region = Rect2(Vector2(0,0),tile_size)

# Focus Animation
func _on_focus_entered() -> void:
	_enlarge_button()

func _on_focus_exited() -> void:
	_normalize_button()

# Mouse Animation
func _on_mouse_entered() -> void:
	_enlarge_button()

func _on_mouse_exited() -> void:
	_normalize_button()

# Button Press Animation
func _on_button_down() -> void:
	_press_button()

func _on_button_up() -> void:
	_normalize_button()

# Animations
func _enlarge_button() -> void:
	z_index += 1
	$AnimationPlayer.play("hover")

func _normalize_button() -> void:
	$AnimationPlayer.play("normalize")
	await $AnimationPlayer.animation_finished
	z_index -= 1

func _press_button() -> void:
	$AnimationPlayer.play("press")
	await $AnimationPlayer.animation_finished
	z_index -= 1
