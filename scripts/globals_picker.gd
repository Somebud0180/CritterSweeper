extends OptionButton
@export var globals_var_name: String

func _ready() -> void:
	selected = Globals.get(globals_var_name)

func _on_item_selected(index: int) -> void:
	Globals.set(globals_var_name, index)

# Standard function to update from globals
func update_value() -> void:
	print(globals_var_name)
	print(Globals.get(globals_var_name))
	selected = Globals.get(globals_var_name)
