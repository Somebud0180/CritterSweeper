extends Button

func _on_pressed() -> void:
	var main_screen = get_tree().root.get_node_or_null("MainScreen")
	if main_screen:
		main_screen.hide_and_show("game", "main")
