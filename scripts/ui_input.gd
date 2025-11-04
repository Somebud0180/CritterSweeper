extends Control

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		Globals.input_type = 1
	elif evetn is InputEventJoypadButton:
		Globals.input_type = 2
	else:
		Globals.input_type = 0
