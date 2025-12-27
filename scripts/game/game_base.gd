extends Control
class_name GameBase

# Core minesweeper game is based on the tutorial by Medium
# https://medium.com/@sergejmoor01/how-to-make-minesweeper-in-godot-4-1a14914d5127

const TILE_SCENE = preload("res://scenes/tile.tscn")
@export var num_mines: int = 40
@export var rows: int = 18 # Number of rows
@export var columns: int = 18 # Number of columns
@export var label: Label
@export var toast: Panel
@export var grid: GridContainer
@export var grid_aspect: AspectRatioContainer
@export var scroll_container: ScrollContainer
@export var critter_layer = Control
var difficulty = 0
var game_mode: GameMode  # Assign ClassicMode or InverseMode resource in inspector
var tiles = [] # 2D array to store tile instances
var last_focused_tile = []
var first_click_done = false
var is_time_counting = false
var game_finished = false

# Score Keeping
var clicks_counted: int = 0    # Amount of clicks done by player (tracked in CritterSeeker)
var blocks_remaining: int = 0  # Amount of unrevealed blocks remaining (tracked in CritterSeeker)
var time_elapsed: float = 0    # Amount of time to finish the game

func _ready() -> void:
	scale = Vector2(0.8, 0.8)
	_set_safe_area_margins()
	get_tree().root.connect("size_changed", _on_viewport_size_changed)
	get_tree().get_first_node_in_group("MainScreen").connect("focus_game", _focus_tile)

func _process(delta: float) -> void:
	if is_time_counting:
		time_elapsed += delta

func start(set_mode: int = 0) -> void:
	match set_mode:
		0:
			game_mode = SweeperMode.new()
		1:
			game_mode = SeekerMode.new()
	
	for child in grid.get_children():
		child.queue_free()
	tiles.clear()
	first_click_done = false
	game_finished = false
	
	clicks_counted = 0
	blocks_remaining = 0
	time_elapsed = 0
	
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 1)
	
	label.text = ""
	label.visible = false
	toast.visible = false
	
	grid.columns = columns
	grid_aspect.ratio = float(columns) / float(rows)
	create_grid()
	
	# Disable tiles
	for row in tiles:
		for tile in row:
			tile.disabled = true
			tile.mouse_default_cursor_shape = CURSOR_ARROW
	
	# Animate critters
	var target_rect = Rect2(
		grid.global_position,
		grid.size
	)
	
	var animation_speed: float
	if num_mines <= 10:
		animation_speed = 1.5
	elif num_mines > 10:
		animation_speed = 2.0
	
	critter_layer.animate_critters(animation_speed, num_mines, target_rect, get_tile_size())
	await critter_layer.critters_finished
	
	tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(1, 1), 1)
	
	# Re-enable tiles
	for row in tiles:
		for tile in row:
			tile.disabled = false
			tile.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	
	_focus_tile()
	is_time_counting = true

func get_tile_size() -> float:
	# Calculate dynamic tile size if needed
	var tile_size_setting = Globals.tile_size
	
	if tile_size_setting <= 1:
		var viewport_size = scroll_container.size
		
		if tile_size_setting == 0:
			# Fit to screen (both width and height)
			var size_by_width = viewport_size.x / columns
			var size_by_height = viewport_size.y / rows
			return min(size_by_width, size_by_height)
		else: # tile_size_setting == 1
			# Fit to screen width only
			return viewport_size.x / columns
	
	return 0

func update_tile_sizes():
	var calculated_tile_size: float = get_tile_size()
	
	# Apply tile size to all existing tiles
	for row in tiles:
		for tile in row:
			if calculated_tile_size > 1:
				tile.set_tile_size(calculated_tile_size)
			else:
				tile.set_tile_size() # Use predefined size from Globals

func create_grid():
	for y in range(rows):
		tiles.append([])
		for x in range(columns):
			var tile = TILE_SCENE.instantiate()
			tile.position = Vector2(x, y) * tile.tile_size
			tile.tile_pressed.connect(_on_tile_pressed.bind(x,y))
			tiles[y].append(tile)
			grid.add_child(tile)
	
	update_tile_sizes()
	calculate_adjacent_mines()

func generate_mine_positions(first_click_position: Vector2i) -> Array:
	var excluded = get_excluded_positions(first_click_position)
	var valid_positions = []
	for y in range(rows):
		for x in range(columns):
			var pos = Vector2i(x, y)
			if pos in excluded:
				continue
			valid_positions.append(pos)
	
	var max_possible_mines = valid_positions.size()
	var mines_to_place = mini(num_mines, max_possible_mines)
	
	valid_positions.shuffle()
	return valid_positions.slice(0, mines_to_place)

func get_excluded_positions(first_click_position: Vector2i) -> Array:
	if not game_mode or not game_mode.should_protect_first_click():
		return []
	
	var excluded = []
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var check_pos = first_click_position + Vector2i(dx, dy)
			if check_pos.x >= 0 and check_pos.x < columns and check_pos.y >= 0 and check_pos.y < rows:
				excluded.append(check_pos)
	return excluded

func place_mines(first_click_position: Vector2i) -> void:
	var mine_positions = generate_mine_positions(first_click_position)
	for pos in mine_positions:
		tiles[pos.y][pos.x].is_mine = true
	calculate_adjacent_mines()

func count_adjacent_mines(x: int, y: int) -> int:
	var count = 0
	for dy in range (-1, 2): # Iterate over vertical neighbors (-1 to 1)
		for dx in range(-1, 2): # Iterate over horizontal neighbors (-1 to 1)
			if dx == 0 and dy == 0:
				continue # Skip the current tile itself
			
			var nx = x + dx
			var ny = y + dy
			
			# Check if the neighbor is within bounds
			if nx >= 0 and ny >= 0 and nx < columns and ny < rows:
				if tiles[ny][nx].is_mine:
					count += 1
	
	return count

func calculate_adjacent_mines():
	for y in range(rows):
		for x in range(columns):
			var tile = tiles[y][x]
			if not tile.is_mine:
				tile.adjacent_mines = count_adjacent_mines(x, y)

func reveal_tile_and_neighbors(x: int, y: int):
	if x < 0 or y < 0 or x >= columns or y >= rows:
		return
	
	var tile = tiles[y][x]
	if tile.is_revealed or tile.is_mine:
		return
	
	tile.reveal_tile()
	
	# If no adjacent mines, reveal neighbors
	if tile.adjacent_mines == 0:
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				if dx != 0 or dy != 0:
					reveal_tile_and_neighbors(x + dx, y + dy)

func evaluate_end_state() -> void:
	if game_finished or not game_mode:
		return
	if game_mode.is_win_state(tiles):
		game_won()
	elif game_mode.is_loss_state(tiles):
		game_over()

func game_over():
	is_time_counting = false
	game_finished = true
	for row in tiles:
		for tile in row:
			tile.disabled = true
			tile.mouse_default_cursor_shape = CURSOR_FORBIDDEN
			if game_mode:
				game_mode.reveal_tile_on_game_over(tile)
	
	label.text = "Game Over!"
	label.visible = true
	toast.visible = true

func game_won():
	is_time_counting = false
	game_finished = true
	for row in tiles:
		for tile in row:
			tile.disabled = true
			tile.mouse_default_cursor_shape = CURSOR_ARROW
	label.text = "You Won!"
	label.visible = true
	toast.visible = true
	
	if game_mode is SweeperMode:
		Scoreboard.save_sweeper_score(difficulty, time_elapsed)
	elif game_mode is SeekerMode:
		blocks_remaining = count_unrevealed_blocks()
		Scoreboard.save_seeker_score(difficulty, clicks_counted, blocks_remaining, time_elapsed)

## Tile Functions
func _on_tile_pressed(x: int, y: int):
	if game_finished or not game_mode:
		return
	
	clicks_counted += 1
	var tile = tiles[y][x]
	if not first_click_done:
		first_click_done = true
		place_mines(Vector2i(x, y))
	
	if tile.is_mine:
		tile.reveal_tile(game_mode.mine_reveal_is_original_press())
		if game_mode.should_end_on_mine_press():
			game_over()
			return
	else:
		reveal_tile_and_neighbors(x, y)
	
	evaluate_end_state()

func count_unrevealed_blocks() -> int:
	var count = 0
	for row in tiles:
		for tile in row:
			if !tile.is_revealed:
				count += 1
	return count

## Focus Functions
func _save_last_focused() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	if focused and grid.is_ancestor_of(focused):
		last_focused_tile = focused

func _on_tile_focus_entered(tile: Control) -> void:
	last_focused_tile = tile

func _focus_tile() -> void:
	if Globals.input_type == 2:
		if is_instance_valid(last_focused_tile):
			last_focused_tile.grab_focus()
		elif tiles.size() > 0 and tiles[0].size() > 0:
			tiles[0][0].grab_focus()

## Viewport Functions
func _on_viewport_size_changed() -> void:
	pivot_offset = Vector2(size.x / 2, size.y / 2)
	update_tile_sizes()
	_set_safe_area_margins()

func _set_safe_area_margins() -> void:
	if not (OS.has_feature("ios") or OS.has_feature("android")):
		return
	
	var rect = DisplayServer.get_display_safe_area() # Safe area in screen/physical pixels
	var screen_size = DisplayServer.screen_get_size() # Entire screen area in screen/physical pixels

	# Calculate how many "logical pixels" correspond to a single physical pixel
	var aspect_x = size.x / screen_size.x
	var aspect_y = size.y / screen_size.y

	# Convert the safe-area rect to logical pixel margins
	var safe_margin_left = rect.position.x * aspect_x
	var safe_margin_top = rect.position.y * aspect_y
	var safe_margin_right = (screen_size.x - (rect.position.x + rect.size.x)) * aspect_x
	var safe_margin_bottom = (screen_size.y - (rect.position.y + rect.size.y)) * aspect_y

	# Get existing margins from scene to preserve them
	var existing_left = get_theme_constant("margin_left", "MarginContainer")
	var existing_top = get_theme_constant("margin_top", "MarginContainer")
	var existing_right = get_theme_constant("margin_right", "MarginContainer")
	var existing_bottom = get_theme_constant("margin_bottom", "MarginContainer")

	# Apply margins to game container - add safe area to existing margins
	add_theme_constant_override("margin_left", int(existing_left + safe_margin_left))
	add_theme_constant_override("margin_top", int(existing_top + safe_margin_top))
	add_theme_constant_override("margin_right", int(existing_right + safe_margin_right))
	add_theme_constant_override("margin_bottom", int(existing_bottom + safe_margin_bottom))
	
	# Apply margins to overlay as well
	var overlay = $"../GameOverlay"
	if overlay:
		var overlay_left = overlay.get_theme_constant("margin_left", "MarginContainer")
		var overlay_top = overlay.get_theme_constant("margin_top", "MarginContainer")
		var overlay_right = overlay.get_theme_constant("margin_right", "MarginContainer")
		var overlay_bottom = overlay.get_theme_constant("margin_bottom", "MarginContainer")
		
		overlay.add_theme_constant_override("margin_left", int(overlay_left + safe_margin_left))
		overlay.add_theme_constant_override("margin_top", int(overlay_top + safe_margin_top))
		overlay.add_theme_constant_override("margin_right", int(overlay_right + safe_margin_right))
		overlay.add_theme_constant_override("margin_bottom", int(overlay_bottom + safe_margin_bottom))
