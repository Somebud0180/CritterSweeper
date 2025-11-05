extends Control

@export var animation_player: AnimationPlayer
@export var sidebar_animation_player: AnimationPlayer
@export var resume_button: TextureButton
@export var start_button: TextureButton

const NEW_GAME_BTNTEXT = preload("res://interface/textures/ButtonTexture/NewGame.png")
const START_GAME_BTNTEXT = preload("res://interface/textures/ButtonTexture/StartGame.png")
const TILE_MODE_OVERLAY = preload("res://scenes/tile_mode_overlay.tscn")
var in_game: bool:
	get:
		return in_game
	set(value):
		in_game = value
		resume_button.visible = in_game
		start_button.texture_normal = NEW_GAME_BTNTEXT if in_game else START_GAME_BTNTEXT

enum STATE { MAIN, GAME, SETTINGS, DIFFICULTY }
var menu_state: STATE:
	get:
		return menu_state
	set(value):
		menu_state = value

func _ready() -> void:
	in_game = false
	menu_state = STATE.MAIN

func hide_and_show(hide_string: String, show_string: String) -> void:
	animation_player.play("hide_" + hide_string)
	await animation_player.animation_finished
	animation_player.play("show_" + show_string)

# Main Menu Buttons
func _on_start_button_pressed() -> void:
	hide_and_show("main", "difficulty")

func _on_resume_button_pressed() -> void:
	hide_and_show("main", "game")
	if Globals.input_type != 0:
		sidebar_animation_player.play("shared_animations/show_flag_mode")

func _on_settings_button_pressed() -> void:
	hide_and_show("main", "settings")

# Difficulty Buttons
func _on_difficulty_button_pressed(difficulty: int) -> void:
	var game_scene = $GameLayer/Game
	game_scene.first_click_done = false
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
	
	game_scene.start()
	hide_and_show("difficulty", "game")
	if Globals.input_type != 0:
		sidebar_animation_player.play("shared_animations/show_flag_mode")

# Settings Functions
func _on_button_pressed() -> void:
	hide_and_show("settings", "main")

func _on_music_volume_value_changed(value: float) -> void:
	Globals.music_vol = value

func _on_sfx_volume_value_changed(value: float) -> void:
	Globals.sfx_vol = value

func update_flag_mode() -> void:
	# If Keyboard and Mouse, catch 
	print("Updating Flag Mode; Input type: {input_type}".format({"input_type": Globals.input_type}))
	if Globals.input_type == 0:
		sidebar_animation_player.play("shared_animations/hide_flag_mode")
		return
	
	print("Updating Flag Mode")
	if Globals.flag_mode == 0:
		sidebar_animation_player.play("shared_animations/hide_flag_mode")
	elif Globals.flag_mode == 1 and in_game and menu_state == STATE.GAME:
		sidebar_animation_player.play("shared_animations/show_flag_mode")

func _input(event: InputEvent) -> void:
	var new_input_type = 0
	if event is InputEventScreenTouch:
		new_input_type = 1
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		new_input_type = 2
	else:
		new_input_type = 0
	
	# Reduce unnecessary updates
	if Globals.input_type != new_input_type:
		Globals.input_type = new_input_type
	
	if (event.is_action_pressed("ui_cancel") or event.is_action_pressed("go_back")) and not animation_player.is_playing():
		match menu_state:
			STATE.MAIN:
				if in_game:
					hide_and_show("main", "game")
			STATE.GAME:
				hide_and_show("game", "main")
			STATE.SETTINGS:
				hide_and_show("settings", "main")
			STATE.DIFFICULTY:
				hide_and_show("difficulty", "main")
