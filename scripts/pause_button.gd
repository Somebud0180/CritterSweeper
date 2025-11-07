extends TextureButton

var main_screen

func _ready() -> void:
	main_screen = get_tree().get_first_node_in_group("MainScreen")
	
func _on_pressed() -> void:
	if main_screen:
		main_screen.hide_and_show("game", "main")
		if main_screen.sidebar_visible:
			main_screen.sidebar_animation_player.play("shared_animations/hide_flag_mode")
