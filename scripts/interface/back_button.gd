extends TextureButton
@export var current_menu: String
@export var previous_menu: String
var main_screen

func _ready() -> void:
	main_screen = get_tree().get_first_node_in_group("MainScreen")
	connect("button_down", _press_button)
	connect("button_up", _normalize_button)
	connect("focus_entered", _enlarge_button)
	connect("focus_exited", _normalize_button)
	connect("mouse_entered", _enlarge_button)
	connect("mouse_exited", _normalize_button)
	
	get_tree().root.connect("size_changed", _on_viewport_size_changed)
	pivot_offset = Vector2(size.x/2, size.y/2)

func _on_pressed() -> void:
	main_screen.hide_and_show(current_menu, previous_menu)

func _on_viewport_size_changed() -> void:
	pivot_offset = Vector2(size.x/2, size.y/2)

# Animations
func _enlarge_button() -> void:
	z_index = 0
	z_index += 1
	$ButtonAnimations.play("enlarge")
	Globals.vibrate_stop()
	Globals.vibrate_hover()

func _normalize_button() -> void:
	$ButtonAnimations.play("normalize")
	await $ButtonAnimations.animation_finished
	z_index = 0

func _press_button() -> void:
	$ButtonAnimations.play("press")
	Globals.vibrate_hard_press()
	await $ButtonAnimations.animation_finished
	z_index = 0
