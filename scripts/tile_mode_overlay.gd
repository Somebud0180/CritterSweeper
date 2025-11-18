extends VBoxContainer

func _on_reveal_mode_pressed() -> void:
	Globals.is_flagging = false

func _on_flag_mode_pressed() -> void:
	Globals.is_flagging = true

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		if event.is_action_pressed("toggle_flag"):
			Globals.is_flagging = !Globals.is_flagging
