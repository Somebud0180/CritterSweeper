extends Node

class SeekerScore:
	var clicks_counted: int
	var blocks_remaining: int
	var time_elapsed: float

var sweeper_scores: Array[float] = []
var seeker_scores: Array[SeekerScore] = []

### Internal Functions
func _ready() -> void:
	_load_config()

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
	
	sweeper_scores = config.get_value("Scores", "sweeper_scores", [])

	# Reconstruct SeekerScore objects from stored dictionaries
	seeker_scores.clear()
	var stored_seeker_scores = config.get_value("Scores", "seeker_scores", [])
	for stored_score in stored_seeker_scores:
		if stored_score is Dictionary:
			var score = SeekerScore.new()
			score.clicks_counted = stored_score.get("clicks_counted", 0)
			score.blocks_remaining = stored_score.get("blocks_remaining", 0)
			score.time_elapsed = stored_score.get("time_elapsed", 0.0)
			seeker_scores.append(score)

	print("Sweeper Scores:")
	print(sweeper_scores)
	print("Seeker Scores:")
	for score in seeker_scores:
		print(read_seeker_score(score))

func _save_config() -> void:
	# Create new ConfigFile object.
	var config = ConfigFile.new()
	
	# Store configuration
	config.set_value("Scores", "sweeper_scores", sweeper_scores)
	var stored_seeker_scores: Array = []
	for score in seeker_scores:
		stored_seeker_scores.append({
			"clicks_counted": score.clicks_counted,
			"blocks_remaining": score.blocks_remaining,
			"time_elapsed": score.time_elapsed,
		})
	config.set_value("Scores", "seeker_scores", stored_seeker_scores)
	
	# Save Config
	config.save("user://scores.cfg")
	print("Sweeper Scores:")
	print(sweeper_scores)
	print("Seeker Scores:")
	for score in seeker_scores:
		print(read_seeker_score(score))

## Global Functions
func save_sweeper_score(time_elapsed: float) -> void:
	sweeper_scores.append(time_elapsed)
	sweeper_scores.sort()
	_save_config()

func save_seeker_score(clicks_counted: int, blocks_remaining: int, time_elapsed: float) -> void:
	var new_score = SeekerScore.new()
	new_score.clicks_counted = clicks_counted
	new_score.blocks_remaining = blocks_remaining
	new_score.time_elapsed = time_elapsed
	
	seeker_scores.append(new_score)
	seeker_scores.sort_custom(_sort_seeker_score)
	_save_config()

func read_seeker_score(score: SeekerScore) -> Array:
	return [score.clicks_counted, score.blocks_remaining, score.time_elapsed]
