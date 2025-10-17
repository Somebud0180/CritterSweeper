extends Node2D

# Core minesweeper game is based on the tutorial by Medium
# https://medium.com/@sergejmoor01/how-to-make-minesweeper-in-godot-4-1a14914d5127

const TILE_SCENE = preload("res://scenes/tile.tscn")
@export var num_mines: int = 40
@export var rows: int = 18 # Number of rows
@export var columns: int = 18 # Number of columns
var tiles = [] # 2D array to store tile instances

func _ready() -> void:
	create_grid()

func create_grid():
	var mine_positions = generate_mine_positions()
	
	for y in range(rows):
		tiles.append([])
		for x in range(columns):
			var tile = TILE_SCENE.instantiate()
			tile.position = Vector2(x, y) * tile.tile_size
			tile.is_mine = Vector2i(x, y) in mine_positions
			tile.tile_pressed.connect(_on_tile_pressed.bind(x,y))
			tiles[y].append(tile)
			$Grid.add_child(tile)
	
	calculate_adjacent_mines()

func generate_mine_positions():
	randomize()
	var mine_positions = []
	while mine_positions.size() < num_mines:
		var pos = Vector2i(randi() % columns, randi() % rows)
		if pos not in mine_positions:
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

func _on_tile_pressed(x: int, y: int):
	var tile = tiles[y][x]
	if tile.is_mine:
		game_over()
	else:
		print("revealing")
		reveal_tile_and_neighbors(x, y)

func reveal_tile_and_neighbors(x: int, y: int):
	if x < 0 or y < 0 or x >= columns or y >= rows:
		print("reveal return: 0")
		return
	
	var tile = tiles[y][x]
	if tile.is_revealed or tile.is_mine:
		print("reveal return: 1")
		return
	
	tile.reveal_tile()
	
	# If no adjacent mines, reveal neighbors
	if tile.adjacent_mines == 0:
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				if dx != 0 or dy != 0:
					reveal_tile_and_neighbors(x + dx, y + dy)

func game_over():
	for row in tiles:
		for tile in row:
			tile.disabled = true;
			if tile.is_mine:
				tile.reveal_tile()
	
	$ColorRect/Label.text = "Game Over!"
	$ColorRect/Label.visible = true
