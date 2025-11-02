extends TextureButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("button_down", _press_button)
	connect("button_up", _normalize_button)
	connect("focus_entered", _enlarge_button)
	connect("focus_exited", _normalize_button)
	connect("mouse_entered", _enlarge_button)
	connect("mouse_exited", _normalize_button)
	
	get_tree().root.connect("size_changed", _on_viewport_size_changed)
	pivot_offset = Vector2(size.x/2, size.y/2)

func _on_viewport_size_changed() -> void:
	pivot_offset = Vector2(size.x/2, size.y/2)

# Animations
func _enlarge_button() -> void:
	z_index = 0
	z_index += 1
	$ButtonAnimations.play("enlarge")

func _normalize_button() -> void:
	$ButtonAnimations.play("normalize")
	await $ButtonAnimations.animation_finished
	z_index = 0

func _press_button() -> void:
	$ButtonAnimations.play("press")
	await $ButtonAnimations.animation_finished
	z_index = 0
