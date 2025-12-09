extends Control

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
var tiles = [] # 2D array to store tile instances
var last_focused_tile = []
var first_click_done = false

func _ready() -> void:
	get_tree().root.connect("size_changed", _on_viewport_size_changed)
	get_tree().get_first_node_in_group("MainScreen").connect("focus_game", _focus_tile)

func start() -> void:
	for child in grid.get_children():
		child.queue_free()
	tiles.clear()
	
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
	
	# Re-enable tiles
	for row in tiles: 
		for tile in row:
			tile.disabled = false
			tile.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	
	_focus_tile()

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

func _on_tile_pressed(x: int, y: int):
	var tile = tiles[y][x]
	if not first_click_done:
		first_click_done = true
		# Add mines, excluding the first clicks position
		var mine_positions = generate_mine_positions(Vector2i(x, y))
		for pos in mine_positions:
			tiles[pos.y][pos.x].is_mine = true
		calculate_adjacent_mines()
	
	if tile.is_mine:
		tile.reveal_tile(true)
		game_over()
	else:
		reveal_tile_and_neighbors(x, y)
		if check_win_condition():
			game_won()

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
	print("Target mines: ", num_mines)
	
	var first_click_positions = []
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var check_pos = first_click_position + Vector2i(dx, dy)
			if check_pos.x >= 0 and check_pos.x < columns and check_pos.y >= 0 and check_pos.y < rows:
				first_click_positions.append(check_pos)
	
	var valid_positions = []
	for y in range(rows):
		for x in range(columns):
			var pos = Vector2i(x, y)
			if pos not in first_click_positions:
				valid_positions.append(pos)
	
	var max_possible_mines = valid_positions.size()
	var mines_to_place = mini(num_mines, max_possible_mines)
	
	valid_positions.shuffle()
	var mine_positions = valid_positions.slice(0, mines_to_place)
	
	return mine_positions

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

func check_win_condition():
	for row in tiles:
		for tile in row:
			if not tile.is_revealed and not tile.is_mine:
				# If any non-mine tile is not revealed, the player hasn't won
				return false
	return true # All non-mine tiles are revealed

func game_over():
	for row in tiles:
		for tile in row:
			tile.disabled = true
			tile.mouse_default_cursor_shape = CURSOR_FORBIDDEN
			if tile.is_mine:
				tile.reveal_tile()
	
	label.text = "Game Over!"
	label.visible = true
	toast.visible = true
	
func game_won():
	for row in tiles:
		for tile in row:
			tile.disabled = true
			tile.mouse_default_cursor_shape = CURSOR_ARROW
	label.text = "You Won!"
	label.visible = true
	toast.visible = true

func restart_game():
	first_click_done = false
	last_focused_tile = null
	
	for child in grid.get_children():
		child.queue_free()
	tiles.clear()
	
	label.text = ""
	label.visible = false
	toast.visible = false
	
	create_grid()

func _on_viewport_size_changed() -> void:
	update_tile_sizes()
