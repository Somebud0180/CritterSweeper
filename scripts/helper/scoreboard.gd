extends Node

# Sort Enum
enum SORT_BY { GAME, CLICKS, TILES, TIME }

## Score Classes
class SweeperScore:
	var game_number: int
	var difficulty: int
	var time_elapsed: float

class SeekerScore:
	var game_number: int
	var difficulty: int
	var clicks_counted: int
	var tiles_remaining: int
	var time_elapsed: float

## Variables
var sweeper_scores: Array[SweeperScore] = []
var seeker_scores: Array[SeekerScore] = []

### Internal Functions
func _ready() -> void:
	_load_config()

func _read_sweeper_score(score: SweeperScore) -> Array:
	return [score.game_number, score.difficulty,  score.time_elapsed]

func _read_seeker_score(score: SeekerScore) -> Array:
	return [score.game_number, score.difficulty, score.clicks_counted, score.tiles_remaining, score.time_elapsed]

func _load_config() -> void:
	var config = ConfigFile.new()
	
	# Load data from a file.
	var err = config.load("user://scores.cfg")
	
	# If the file didn't load, ignore it.
	if err != OK:
		print("Failed to load config")
		return
	
	# Get scores
	# Sweeper Scores
	sweeper_scores.clear()
	var stored_sweeper_scores = config.get_value("Scores", "sweeper_scores", [])
	for stored_score in stored_sweeper_scores:
		if stored_score is Dictionary:
			var score = SweeperScore.new()
			score.game_number = stored_score.get("game_number", 0)
			score.difficulty = stored_score.get("difficulty", 0)
			score.time_elapsed = stored_score.get("time_elapsed", 0.0)
			sweeper_scores.append(score)
	
	# Seeker Scores
	seeker_scores.clear()
	var stored_seeker_scores = config.get_value("Scores", "seeker_scores", [])
	for stored_score in stored_seeker_scores:
		if stored_score is Dictionary:
			var score = SeekerScore.new()
			score.game_number = stored_score.get("game_number", 0)
			score.difficulty = stored_score.get("difficulty", 0)
			score.clicks_counted = stored_score.get("clicks_counted", 0)
			score.tiles_remaining = stored_score.get("tiles_remaining", 0)
			score.time_elapsed = stored_score.get("time_elapsed", 0.0)
			seeker_scores.append(score)

func _save_config() -> void:
	# Create new ConfigFile object.
	var config = ConfigFile.new()
	
	# Store scores
	# Sweeper Scores
	var stored_sweeper_scores: Array = []
	for score in sweeper_scores:
		stored_sweeper_scores.append({
			"game_number": score.game_number,
			"difficulty": score.difficulty,
			"time_elapsed": score.time_elapsed,
		})
	config.set_value("Scores", "sweeper_scores", stored_sweeper_scores)
	
	# Seeker Scores
	var stored_seeker_scores: Array = []
	for score in seeker_scores:
		stored_seeker_scores.append({
			"game_number": score.game_number,
			"difficulty": score.difficulty,
			"clicks_counted": score.clicks_counted,
			"tiles_remaining": score.tiles_remaining,
			"time_elapsed": score.time_elapsed,
		})
	config.set_value("Scores", "seeker_scores", stored_seeker_scores)
	
	# Save Config
	config.save("user://scores.cfg")

## Class Functions (Sort and Filter)
func _sort_by_game_number(a, b) -> bool:
	return a.game_number < b.game_number

func _get_next_game_number() -> int:
	var max_number = 0
	for score in sweeper_scores:
		if score.game_number > max_number:
			max_number = score.game_number
	for score in seeker_scores:
		if score.game_number > max_number:
			max_number = score.game_number
	return max_number + 1

## Global Functions
func save_sweeper_score(difficulty: int, time_elapsed: float) -> void:
	var new_score = SweeperScore.new()
	new_score.game_number = _get_next_game_number()
	new_score.difficulty = difficulty
	new_score.time_elapsed = snapped(time_elapsed, 0.01)
	
	sweeper_scores.append(new_score)
	sweeper_scores.sort_custom(_sort_by_game_number)
	_save_config()

func save_seeker_score(difficulty: int, clicks_counted: int, tiles_remaining: int, time_elapsed: float) -> void:
	var new_score = SeekerScore.new()
	new_score.game_number = _get_next_game_number()
	new_score.difficulty = difficulty
	new_score.clicks_counted = clicks_counted
	new_score.tiles_remaining = tiles_remaining
	new_score.time_elapsed = snapped(time_elapsed, 0.01)
	
	seeker_scores.append(new_score)
	seeker_scores.sort_custom(_sort_by_game_number)
	_save_config()

func get_scores(game_mode: int, difficulty: int, sort_by: SORT_BY, descending: bool) -> Array:
	var filtered_scores: Array
	match game_mode:
		0:
			for score in sweeper_scores:
				if score.difficulty == difficulty:
					filtered_scores.append(_read_sweeper_score(score))
			# Sort sweeper scores by time (only relevant sort for sweeper mode)
			filtered_scores.sort_custom(func(a, b): return a[1] < b[1])
		1:
			for score in seeker_scores:
				if score.difficulty == difficulty:
					filtered_scores.append(_read_seeker_score(score))
			# Sort seeker scores based on sort_by parameter
			match sort_by:
				SORT_BY.CLICKS:
					filtered_scores.sort_custom(func(a, b): return a[1] < b[1])
				SORT_BY.TILES:
					filtered_scores.sort_custom(func(a, b): return a[2] < b[2])
				SORT_BY.TIME:
					filtered_scores.sort_custom(func(a, b): return a[3] < b[3])
	
	# Reverse array if descending order is requested
	if descending:
		filtered_scores.reverse()
	
	return filtered_scores
