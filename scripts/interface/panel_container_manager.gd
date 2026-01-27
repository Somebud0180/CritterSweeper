extends PanelContainer

func _ready() -> void:
	_on_viewport_size_changed()
	get_tree().root.connect("size_changed", _on_viewport_size_changed)

func _on_viewport_size_changed() -> void:
	var rect = DisplayServer.get_display_safe_area() # Safe area in screen/physical pixels
	var screen_size = DisplayServer.screen_get_size() # Entire screen area in screen/physical pixels
	
	if screen_size.x < screen_size.y:
		offset_right = 0
	else:
		offset_right = -144
	
	# Calculate how many "logical pixels" correspond to a single physical pixel
	var aspect_x = size.x / screen_size.x
	var aspect_y = size.y / screen_size.y

	# Convert the safe-area rect to logical pixel margins
	var safe_margin_left = rect.position.x * aspect_x
	var safe_margin_top = rect.position.y * aspect_y
	var safe_margin_right = (screen_size.x - (rect.position.x + rect.size.x)) * aspect_x
	var safe_margin_bottom = (screen_size.y - (rect.position.y + rect.size.y)) * aspect_y

	# Get existing margins from scene to preserve them
	var margin_container = get_child(0)
	var existing_left = margin_container.get_theme_constant("margin_left", "MarginContainer")
	var existing_top = margin_container.get_theme_constant("margin_top", "MarginContainer")
	var existing_right = margin_container.get_theme_constant("margin_right", "MarginContainer")
	var existing_bottom = margin_container.get_theme_constant("margin_bottom", "MarginContainer")

	# Apply margins to game container - add safe area to existing margins
	margin_container.add_theme_constant_override("margin_left", int(existing_left + safe_margin_left))
	margin_container.add_theme_constant_override("margin_top", int(existing_top + safe_margin_top))
	margin_container.add_theme_constant_override("margin_right", int(existing_right + safe_margin_right))
	margin_container.add_theme_constant_override("margin_bottom", int(existing_bottom + safe_margin_bottom))
