extends AspectRatioContainer

@onready var ScoreLabel = $"Scoreboard/PanelContainer/VBoxContainer/Score Container/VBoxContainer/RichTextLabel"
@onready var GameSortButton = $"Scoreboard/PanelContainer/VBoxContainer/Score Container/VBoxContainer/SortContainer/Game"
@onready var ClicksSortButton = $"Scoreboard/PanelContainer/VBoxContainer/Score Container/VBoxContainer/SortContainer/Clicks"
@onready var TilesSortButton = $"Scoreboard/PanelContainer/VBoxContainer/Score Container/VBoxContainer/SortContainer/Tiles Remaining"
@onready var TimeSortButton = $"Scoreboard/PanelContainer/VBoxContainer/Score Container/VBoxContainer/SortContainer/Time"

const CHEVRON_UP_TEX = preload("res://assets/interface/textures/glyphs/ChevronUp.png")
const CHEVRON_DOWN_TEX = preload("res://assets/interface/textures/glyphs/ChevronDown.png")

var last_sort_option: int = 0
var game_mode: int = 0
var difficulty: int = 0
var sort_by: Scoreboard.SORT_BY = Scoreboard.SORT_BY.TIME
var descending: bool = false

# Internal Functions
func _ready() -> void:
	_on_sort_button_pressed(0)

func _display_score() -> void:
	var scores = Scoreboard.get_scores(game_mode, difficulty, sort_by, descending)

## Picker Functions
func _on_game_mode_picker_item_selected(index: int) -> void:
	# Reset sort on game mode change
	sort_by = Scoreboard.SORT_BY.TIME
	game_mode = index

func _on_difficulty_picker_item_selected(index: int) -> void:
	difficulty = index

func _on_sort_button_pressed(sort_option: int) -> void:
	var same_as_last = sort_option == last_sort_option
	if same_as_last:
		descending = !descending
	else:
		descending = false
		last_sort_option = sort_option
	
	for button in get_tree().get_nodes_in_group("ScoreSortButton"):
		button.icon = null
		button.button_pressed = false
	
	match sort_option:
		0:
			GameSortButton.icon = CHEVRON_UP_TEX if descending else CHEVRON_DOWN_TEX
			GameSortButton.button_pressed = true
			sort_by = Scoreboard.SORT_BY.GAME
		1:
			ClicksSortButton.icon = CHEVRON_UP_TEX if descending else CHEVRON_DOWN_TEX
			ClicksSortButton.button_pressed = true
			sort_by = Scoreboard.SORT_BY.CLICKS
		2:
			TilesSortButton.icon = CHEVRON_UP_TEX if descending else CHEVRON_DOWN_TEX
			TilesSortButton.button_pressed = true
			sort_by = Scoreboard.SORT_BY.TILES
		3:
			TimeSortButton.icon = CHEVRON_UP_TEX if descending else CHEVRON_DOWN_TEX
			TimeSortButton.button_pressed = true
			sort_by = Scoreboard.SORT_BY.TIME
	
	_display_score()
