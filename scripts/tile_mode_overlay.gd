extends VBoxContainer

func _on_reveal_mode_pressed() -> void:
	Globals.is_flagging = false

func _on_flag_mode_pressed() -> void:
	Globals.is_flagging = true
