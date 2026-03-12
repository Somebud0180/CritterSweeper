extends AspectRatioContainer

@warning_ignore("unused_signal")
signal update_score

@onready var ScoreContainer = $"Scoreboard/PanelContainer/VBoxContainer/VBoxContainer/Score Container/ScoreVBox"
@onready var GameSortButton = $Scoreboard/PanelContainer/VBoxContainer/VBoxContainer/SortContainer/Game
@onready var ClicksSortButton = $Scoreboard/PanelContainer/VBoxContainer/VBoxContainer/SortContainer/Clicks
@onready var TilesSortButton = $"Scoreboard/PanelContainer/VBoxContainer/VBoxContainer/SortContainer/Tiles Remaining"
@onready var TimeSortButton = $Scoreboard/PanelContainer/VBoxContainer/VBoxContainer/SortContainer/Time

const SCORE_LABEL = preload("res://scenes/score_label.tscn")
const CHEVRON_UP_TEX = preload("res://assets/interface/textures/glyphs/ChevronUp.png")
const CHEVRON_UP_WHITE_TEX = preload("res://assets/interface/textures/glyphs/ChevronUp_White.png")
const CHEVRON_DOWN_TEX = preload("res://assets/interface/textures/glyphs/ChevronDown.png")
const CHEVRON_DOWN_WHITE_TEX = preload("res://assets/interface/textures/glyphs/ChevronDown_White.png")

var last_sort_option: int = 0
var game_mode: int = 0
var difficulty: int = 0
var sort_by: Scoreboard.SORT_BY = Scoreboard.SORT_BY.TIME
var descending: bool = false

# Internal Functions
func _ready() -> void:
	_on_game_mode_picker_item_selected(0)
	_on_sort_button_pressed(0)

func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_refresh_sort_icons()

func _display_score() -> void:
	for child in ScoreContainer.get_children():
		child.queue_free()
	
	var scores = Scoreboard.get_scores(game_mode, difficulty, sort_by, descending)
	for score in scores:
		var new_score_label = SCORE_LABEL.instantiate()
		new_score_label.game_mode = game_mode
		
		match game_mode:
			0:
				new_score_label.game_number = score[0]
				new_score_label.time = score[1]
			1:
				new_score_label.game_number = score[0]
				new_score_label.clicks = score[1]
				new_score_label.tiles_remaining = score[2]
				new_score_label.time = score[3]
		
		ScoreContainer.add_child(new_score_label)

## Picker Functions
func _on_game_mode_picker_item_selected(index: int) -> void:
	# Reset sort on game mode change
	descending = true
	game_mode = index
	
	if sort_by == Scoreboard.SORT_BY.CLICKS or sort_by == Scoreboard.SORT_BY.TILES:
		_on_sort_button_pressed(3)
	
	_display_score()
	
	match game_mode:
		0:
			ClicksSortButton.visible = false
			TilesSortButton.visible = false
		1:
			ClicksSortButton.visible = true
			TilesSortButton.visible = true

func _on_difficulty_picker_item_selected(index: int) -> void:
	difficulty = index
	descending = false
	_display_score()

func _on_sort_button_pressed(sort_option: int) -> void:
	var same_as_last = sort_option == last_sort_option
	if same_as_last:
		descending = !descending
	else:
		last_sort_option = sort_option
	
	match sort_option:
		0:
			sort_by = Scoreboard.SORT_BY.GAME
		1:
			sort_by = Scoreboard.SORT_BY.CLICKS
		2:
			sort_by = Scoreboard.SORT_BY.TILES
		3:
			sort_by = Scoreboard.SORT_BY.TIME

	_refresh_sort_icons()
	
	_display_score()

func _on_update_score() -> void:
	_display_score()

func _refresh_sort_icons() -> void:
	await get_tree().process_frame
	
	var chevron_up = _get_chevron_up_texture()
	var chevron_down = _get_chevron_down_texture()
	
	for button in get_tree().get_nodes_in_group("ScoreSortButton"):
		button.icon = null
		button.button_pressed = false
	
	match sort_by:
		Scoreboard.SORT_BY.GAME:
			GameSortButton.icon = chevron_up if descending else chevron_down
			GameSortButton.button_pressed = true
		Scoreboard.SORT_BY.CLICKS:
			ClicksSortButton.icon = chevron_up if descending else chevron_down
			ClicksSortButton.button_pressed = true
		Scoreboard.SORT_BY.TILES:
			TilesSortButton.icon = chevron_up if descending else chevron_down
			TilesSortButton.button_pressed = true
		Scoreboard.SORT_BY.TIME:
			TimeSortButton.icon = chevron_up if descending else chevron_down
			TimeSortButton.button_pressed = true

func _get_chevron_up_texture() -> Texture2D:
	return CHEVRON_UP_WHITE_TEX if _is_dark_theme() else CHEVRON_UP_TEX

func _get_chevron_down_texture() -> Texture2D:
	return CHEVRON_DOWN_WHITE_TEX if _is_dark_theme() else CHEVRON_DOWN_TEX

func _is_dark_theme() -> bool:
	return Globals.get_current_theme_name() == "Purp"
