extends HBoxContainer
class_name ScoreLabel

var game_mode: int = 0:
	set(value):
		game_mode = value
		match game_mode:
			0:
				$Clicks.visible = false
				$Remaining.visible = false
			1:
				$Clicks.visible = true
				$Remaining.visible = true

var game_number: int = 0:
	set(value):
		game_number = value
		$"Game #".text = str(game_number)

var clicks: int = 0:
	set(value):
		clicks = value
		$Clicks.text = str(clicks)

var tiles_remaining: int = 0:
	set(value):
		tiles_remaining = value
		$Remaining.text = str(tiles_remaining)

var time: float = 0:
	set(value):
		time = value
		$Time.text = str(time)
