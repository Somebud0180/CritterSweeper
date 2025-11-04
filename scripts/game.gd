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
var tiles = [] # 2D array to store tile instances
var first_click_done = false
var flag_mode:
	get:
		return flag_mode
	set(value):
		flag_mode = value
		for row in tiles:
			for tile in row:
				tile.flag_mode = flag_mode

func _ready() -> void:
	flag_mode = false
	get_tree().root.connect("size_changed", _on_viewport_size_changed)

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

func _on_restart_button_pressed() -> void:
	first_click_done = false;
	restart_game()

func update_tile_sizes():
	# Calculate dynamic tile size if needed
	var tile_size_setting = Globals.tile_size
	var calculated_tile_size: float = 0
	
	if tile_size_setting <= 1:
		var viewport_size = scroll_container.size
		
		if tile_size_setting == 0:
			# Fit to screen (both width and height)
			var size_by_width = viewport_size.x / columns
			var size_by_height = viewport_size.y / rows
			calculated_tile_size = min(size_by_width, size_by_height)
		else: # tile_size_setting == 1
			# Fit to screen width only
			calculated_tile_size = viewport_size.x / columns
	
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
	var first_click_positions = []
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			first_click_positions.append(first_click_position + Vector2i(dx, dy))
	
	randomize()
	var mine_positions = []
	while mine_positions.size() < num_mines:
		var pos = Vector2i(randi() % columns, randi() % rows)
		if pos not in mine_positions and pos not in first_click_positions:
			mine_positions.append(pos)
	
	return mine_positions;

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
			tile.disabled = true;
			if tile.is_mine:
				tile.reveal_tile()
	
	label.text = "Game Over!"
	label.visible = true
	toast.visible = true
	
func game_won():
	for row in tiles:
		for tile in row:
			tile.disabled = true
	label.text = "You Won!"
	label.visible = true
	toast.visible = true

func restart_game():
	for child in grid.get_children():
		child.queue_free()
	tiles.clear()
	
	label.text = ""
	label.visible = false
	toast.visible = false
	
	create_grid()

func _on_viewport_size_changed() -> void:
	update_tile_sizes()

func _on_reveal_mode_pressed() -> void:
	flag_mode = false

func _on_flag_mode_pressed() -> void:
	flag_mode = true
