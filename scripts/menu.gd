extends Control

@export var animation_player: AnimationPlayer
@export var resume_button: Button
@export var restart_button: Button
@export var start_button: Button

var in_game: bool:
	get:
		return in_game
	set(value):
		in_game = value
		resume_button.visible = in_game
		restart_button.visible = in_game
		start_button.visible = !in_game

var music_vol: float = 1.0
var sfx_vol: float = 1.0

func _ready() -> void:
	in_game = false

func hide_and_show(hide_string: String, show_string: String) -> void:
	animation_player.play("hide_" + hide_string)
	await animation_player.animation_finished
	animation_player.play("show_" + show_string)

# Main Menu Buttons
func _on_start_button_pressed() -> void:
	hide_and_show("main", "difficulty")

func _on_resume_button_pressed() -> void:
	hide_and_show("main", "game")

func _on_restart_button_pressed() -> void:
	$GameLayer/Game.first_click_done = false;
	$GameLayer/Game.restart_game()
	hide_and_show("main", "game")

func _on_settings_button_pressed() -> void:
	hide_and_show("main", "settings")

# Difficulty Buttons
func _on_difficulty_button_pressed(difficulty: int) -> void:
	var game_scene = $GameLayer/Game
	in_game = true
	
	match difficulty:
		0:
			game_scene.rows = 9
			game_scene.columns = 9
			game_scene.num_mines = 10
		1:
			game_scene.rows = 16
			game_scene.columns = 16
			game_scene.num_mines = 20
		2:
			game_scene.rows = 30
			game_scene.columns = 16
			game_scene.num_mines = 30
	
	hide_and_show("difficulty", "game")
	game_scene.start()

# Settings Functions
func _on_button_pressed() -> void:
	hide_and_show("settings", "main")

func _on_music_volume_value_changed(value: float) -> void:
	music_vol = value

func _on_sfx_volume_value_changed(value: float) -> void:
	sfx_vol = value
