extends CanvasLayer
## Manages background and foreground parallax layers with theme switching

@onready var background_parallax: Parallax2D = $BackgroundParallax
@onready var foreground_parallax: Parallax2D = $ForegroundParallax
@onready var background_sprite: Sprite2D = $BackgroundParallax/Sprite2D
@onready var foreground_sprite: Sprite2D = $ForegroundParallax/Sprite2D

func _ready() -> void:
	add_to_group("BackgroundLayer")
	reload_theme()

func reload_theme() -> void:
	var theme_name = Globals.get_current_theme_name()
	if theme_name.is_empty():
		push_warning("No theme available to load")
		return
	
	var theme_path = "res://assets/game/sprites/themes/%s" % theme_name
	
	# Load background
	var background_tex = _get_random_texture_from_folder("%s/backgrounds" % theme_path)
	if background_tex:
		background_sprite.texture = background_tex
	else:
		push_error("Failed to load background texture for theme: %s" % theme_name)
		# Fallback: try loading first background if directory reading fails
		_load_fallback_background(theme_path)
	
	# Load foreground
	var foreground_tex = _get_random_texture_from_folder("%s/foregrounds" % theme_path)
	if foreground_tex:
		foreground_sprite.texture = foreground_tex
	else:
		push_error("Failed to load foreground texture for theme: %s" % theme_name)
		# Fallback: try loading first foreground if directory reading fails
		_load_fallback_foreground(theme_path)

func _get_random_texture_from_folder(folder: String) -> Texture2D:
	var texture_paths = _get_texture_paths_from_folder(folder)
	if texture_paths.is_empty():
		return null
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var idx = rng.randi_range(0, texture_paths.size() - 1)
	return load(texture_paths[idx])

func _load_fallback_background(theme_path: String) -> void:
	# Try hardcoded paths for common background file names
	for i in range(5):
		var tex_path = "%s/backgrounds/Background%d.png" % [theme_path, i]
		var tex = load(tex_path)
		if tex:
			background_sprite.texture = tex
			return
	push_error("Could not load any background for theme using fallback paths")

func _load_fallback_foreground(theme_path: String) -> void:
	# Try hardcoded paths for common foreground file names
	for i in range(5):
		var tex_path = "%s/foregrounds/Foreground%d.png" % [theme_path, i]
		var tex = load(tex_path)
		if tex:
			foreground_sprite.texture = tex
			return
	push_error("Could not load any foreground for theme using fallback paths")

func _get_texture_paths_from_folder(folder: String) -> Array:
	var paths := []
	var dir = DirAccess.open(folder)
	if dir == null:
		push_warning("Cannot open folder: %s (expected in exported builds, will use fallback)" % folder)
		return paths
	
	dir.list_dir_begin()
	var fname = dir.get_next()
	while fname != "":
		if not dir.current_is_dir():
			var lower = fname.to_lower()
			# skip Godot .import metadata files and accept common texture/resource extensions
			if not fname.ends_with(".import") and (lower.ends_with(".png") or lower.ends_with(".jpg") or lower.ends_with(".jpeg") or lower.ends_with(".webp") or lower.ends_with(".tres") or lower.ends_with(".res")):
				paths.append(_join_path(folder, fname))
		fname = dir.get_next()
	dir.list_dir_end()
	return paths

func _join_path(folder: String, filename: String) -> String:
	if folder.ends_with("/"):
		return folder + filename
	return folder + "/" + filename
