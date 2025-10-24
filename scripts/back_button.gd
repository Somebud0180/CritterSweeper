extends Button

@export var current_menu: String
@export var previous_menu: String
var main_screen

func _ready() -> void:
	main_screen = get_tree().get_first_node_in_group("MainScreen")

func _on_pressed() -> void:
	main_screen.hide_and_show(current_menu, previous_menu)
