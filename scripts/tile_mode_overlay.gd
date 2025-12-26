extends VBoxContainer

const REVEAL_TEXT = preload("res://assets/interface/textures/ButtonTexture/SidebarButtons/RevealButton.png")
const REVEAL_F_TEXT = preload("res://assets/interface/textures/ButtonTexture/SidebarButtons/RevealButton_Focus.png")
const FLAG_TEXT = preload("res://assets/interface/textures/ButtonTexture/SidebarButtons/FlagButton.png")
const FLAG_F_TEXT = preload("res://assets/interface/textures/ButtonTexture/SidebarButtons/FlagButton_Focus.png")

func _on_reveal_mode_pressed() -> void:
	Globals.is_flagging = false
	_update_button_text()

func _on_flag_mode_pressed() -> void:
	Globals.is_flagging = true
	_update_button_text()

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		if event.is_action_pressed("toggle_flag"):
			Globals.is_flagging = !Globals.is_flagging
			_update_button_text()

func _ready() -> void:
	_update_button_text()

func _update_button_text() -> void:
	if Globals.is_flagging:
		$RevealMode.texture_normal = REVEAL_TEXT
		$FlagMode.texture_normal = FLAG_F_TEXT
	else:
		$RevealMode.texture_normal = REVEAL_F_TEXT
		$FlagMode.texture_normal = FLAG_TEXT
