extends Node

## Score Classes
class SweeperScore:
	var difficulty: int
	var time_elapsed: float

class SeekerScore:
	var difficulty: int
	var clicks_counted: int
	var blocks_remaining: int
	var time_elapsed: float

## Variables
var sweeper_scores: Array[SweeperScore] = []
var seeker_scores: Array[SeekerScore] = []

### Internal Functions
func _ready() -> void:
	_load_config()

func _sort_sweeper_score(a: SweeperScore, b: SweeperScore) -> bool:
	return a.time_elapsed < b.time_elapsed

func _sort_seeker_score(a: SeekerScore, b: SeekerScore) -> bool:
	return a.time_elapsed < b.time_elapsed

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
			score.difficulty = stored_score.get("difficulty", 0)
			score.time_elapsed = stored_score.get("time_elapsed", 0.0)
			sweeper_scores.append(score)
	
	# Seeker Scores
	seeker_scores.clear()
	var stored_seeker_scores = config.get_value("Scores", "seeker_scores", [])
	for stored_score in stored_seeker_scores:
		if stored_score is Dictionary:
			var score = SeekerScore.new()
			score.difficulty = stored_score.get("difficulty", 0)
			score.clicks_counted = stored_score.get("clicks_counted", 0)
			score.blocks_remaining = stored_score.get("blocks_remaining", 0)
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
			"difficulty": score.difficulty,
			"time_elapsed": score.time_elapsed,
		})
	config.set_value("Scores", "sweeper_scores", stored_sweeper_scores)
	
	# Seeker Scores
	var stored_seeker_scores: Array = []
	for score in seeker_scores:
		stored_seeker_scores.append({
			"difficulty": score.difficulty,
			"clicks_counted": score.clicks_counted,
			"blocks_remaining": score.blocks_remaining,
			"time_elapsed": score.time_elapsed,
		})
	config.set_value("Scores", "seeker_scores", stored_seeker_scores)
	
	# Save Config
	config.save("user://scores.cfg")

## Global Functions
func save_sweeper_score(difficulty: int, time_elapsed: float) -> void:
	var new_score = SweeperScore.new()
	new_score.difficulty = difficulty
	new_score.time_elapsed = snapped(time_elapsed, 0.01)
	
	sweeper_scores.append(new_score)
	sweeper_scores.sort_custom(_sort_sweeper_score)
	_save_config()

func save_seeker_score(difficulty: int, clicks_counted: int, blocks_remaining: int, time_elapsed: float) -> void:
	var new_score = SeekerScore.new()
	new_score.difficulty = difficulty
	new_score.clicks_counted = clicks_counted
	new_score.blocks_remaining = blocks_remaining
	new_score.time_elapsed = snapped(time_elapsed, 0.01)
	
	seeker_scores.append(new_score)
	seeker_scores.sort_custom(_sort_seeker_score)
	_save_config()

func read_sweeper_score(score: SweeperScore) -> Array:
	return [score.difficulty,  score.time_elapsed]

func read_seeker_score(score: SeekerScore) -> Array:
	return [score.difficulty, score.clicks_counted, score.blocks_remaining, score.time_elapsed]
