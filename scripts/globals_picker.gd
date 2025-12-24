extends OptionButton
@export var globals_var_name: String

func _ready() -> void:
	# For background_theme, dynamically populate items
	if globals_var_name == "background_theme":
		_populate_theme_items()
	
	selected = Globals.get(globals_var_name)

func _populate_theme_items() -> void:
	clear()
	var themes = Globals.get_available_themes()
	for i in range(themes.size()):
		add_item(themes[i], i)

func _on_item_selected(index: int) -> void:
	Globals.set(globals_var_name, index)

# Standard function to update from globals
func update_value() -> void:
	selected = Globals.get(globals_var_name)
