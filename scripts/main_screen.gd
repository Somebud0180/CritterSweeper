extends Control

@warning_ignore("unused_signal") signal focus_game

@export var animation_player: AnimationPlayer
@export var sidebar_animation_player: AnimationPlayer
@export var resume_button: TextureButton
@export var start_button: TextureButton

const NEW_GAME_BTNTEXT = preload("res://interface/textures/ButtonTexture/MenuButtons/NewGame.png")
const START_GAME_BTNTEXT = preload("res://interface/textures/ButtonTexture/MenuButtons/StartGame.png")
const TILE_MODE_OVERLAY = preload("res://scenes/tile_mode_overlay.tscn")

enum STATE { MAIN, GAME, SETTINGS, DIFFICULTY }
var menu_state: STATE:
	get:
		return menu_state
	set(value):
		menu_state = value

var in_game: bool:
	get:
		return in_game
	set(value):
		in_game = value
		resume_button.visible = in_game
		start_button.texture_normal = NEW_GAME_BTNTEXT if in_game else START_GAME_BTNTEXT

var sidebar_visible = false

func _ready() -> void:
	in_game = false
	animation_player.play("show_main")

func hide_and_show(hide_string: String, show_string: String) -> void:
	animation_player.play("hide_" + hide_string)
	await animation_player.animation_finished
	
	if show_string == "game":
		_apply_safe_area_offset()
	
	animation_player.play("show_" + show_string)

func update_flag_mode() -> void:
	# If Keyboard and Mouse, catch and hide sidebar
	if Globals.input_type == 0:
		if sidebar_visible:
			sidebar_animation_player.play("shared_animations/hide_flag_mode")
		return
	
	if Globals.flag_mode == 0 and sidebar_visible:
		sidebar_animation_player.play("shared_animations/hide_flag_mode")
	elif Globals.flag_mode == 1 and menu_state == STATE.GAME and !sidebar_visible:
		sidebar_animation_player.play("shared_animations/show_flag_mode")

func focus_main_menu() -> void:
	if in_game:
		resume_button.grab_focus()
	else:
		start_button.grab_focus()

func _input(event: InputEvent) -> void:
	var new_input_type = _check_input_type(event)
	# Reduce unnecessary updates
	if Globals.input_type != new_input_type:
		Globals.input_type = new_input_type
		update_flag_mode()
	
	if (event.is_action_pressed("ui_cancel") or event.is_action_pressed("go_back")) and not animation_player.is_playing():
		match menu_state:
			STATE.MAIN:
				if in_game:
					hide_and_show("main", "game")
			STATE.GAME:
				# Only open menu if go_back is pressed (affects controllers)
				if event.is_action_pressed("go_back"):
					hide_and_show("game", "main")
			STATE.SETTINGS:
				hide_and_show("settings", "main")
			STATE.DIFFICULTY:
				hide_and_show("difficulty", "main")

func _check_input_type(event: InputEvent) -> int:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		return 1
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return 2
	elif event is InputEventMouseButton or event is InputEventMouseMotion:
		# Check if mouse event is emulated from touch
		if event.device == InputEvent.DEVICE_ID_EMULATION:
			return 1
		return 0
	else:
		# Unknown event type - maintain current input type
		return Globals.input_type

# Main Menu Buttons
func _on_start_button_pressed() -> void:
	hide_and_show("main", "difficulty")

func _on_resume_button_pressed() -> void:
	hide_and_show("main", "game")

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

# Settings Functions
func _on_button_pressed() -> void:
	hide_and_show("settings", "main")

func _has_notch() -> bool:
	var screen_size = DisplayServer.screen_get_size()
	var usable_rect = DisplayServer.screen_get_usable_rect()
	
	# If usable rect is smaller than screen size, there's a notch or safe area
	return usable_rect.size != screen_size

func _get_safe_area_offset() -> Vector2:
	var screen_size = DisplayServer.screen_get_size()
	var usable_rect = DisplayServer.screen_get_usable_rect()
	
	# Calculate padding needed for safe area
	var offset = Vector2.ZERO
	
	# Top padding (most common for notches)
	if usable_rect.position.y > 0:
		offset.y = usable_rect.position.y
	
	# Left padding
	if usable_rect.position.x > 0:
		offset.x = usable_rect.position.x
	
	return offset

func _apply_safe_area_offset() -> void:
	var game_layer = $GameLayer
	var offset = _get_safe_area_offset()
	
	# Apply the offset as a position adjustment
	game_layer.position = offset
