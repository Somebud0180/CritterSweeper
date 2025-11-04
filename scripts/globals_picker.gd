extends OptionButton
@export var globals_var_name: String

func _on_item_selected(index: int) -> void:
	print(index)
	Globals.set(globals_var_name, index) 
