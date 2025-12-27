extends AspectRatioContainer

@onready var ScoreLabel = $"Scoreboard/PanelContainer/VBoxContainer/Score Container/VBoxContainer/RichTextLabel"

var game_mode: int = 0
var difficulty: int = 0
var sort_by: Scoreboard.SORT_BY = Scoreboard.SORT_BY.TIME
var descending: bool = false

# Internal Functions
func _display_score() -> void:
	var scores = Scoreboard.get_scores(game_mode, difficulty, sort_by, descending)

## Picker Functions
func _on_game_mode_picker_item_selected(index: int) -> void:
	# Reset sort on game mode change
	sort_by = Scoreboard.SORT_BY.TIME
	game_mode = index

func _on_difficulty_picker_item_selected(index: int) -> void:
	difficulty = index
