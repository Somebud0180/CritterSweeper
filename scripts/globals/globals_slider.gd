extends HSlider
@export var globals_var_name: String

func _ready() -> void:
	value = min(max(Globals.get(globals_var_name), min_value), max_value)

func _on_value_changed(new_value: float) -> void:
	Globals.set(globals_var_name, new_value)

# Standard function to update from globals
func update_value() -> void:
	set_value_no_signal(min(max(Globals.get(globals_var_name), min_value), max_value))
