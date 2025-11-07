extends CheckButton
@export var globals_var_name: String

func _ready() -> void:
	button_pressed = Globals.get(globals_var_name)
	
func _on_toggled(toggled_on: bool) -> void:
	Globals.set(globals_var_name, toggled_on)

# Standard function to update from globals
func update_value() -> void:
	button_pressed = Globals.get(globals_var_name)
