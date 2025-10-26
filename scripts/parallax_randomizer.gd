extends Parallax2D

@export_dir var textures_folder

func _ready() -> void:
	randomize_foreground()

func _join_path(folder: String, filename: String) -> String:
	if folder.ends_with("/"):
		return folder + filename
	return folder + "/" + filename

func _get_texture_paths_from_folder(folder: String) -> Array:
	var paths := []
	var dir = DirAccess.open(folder)
	if dir == null:
		push_error("Cannot open folder: %s" % folder)
		return paths
	dir.list_dir_begin()
	var fname = dir.get_next()
	while fname != "":
		if not dir.current_is_dir():
			var lower = fname.to_lower()
			# skip Godot .import metadata files and accept common texture/resource extensions
			if not fname.to_lower().ends_with(".import") and (lower.ends_with(".png") or lower.ends_with(".jpg") or lower.ends_with(".jpeg") or lower.ends_with(".webp") or lower.ends_with(".tres") or lower.ends_with(".res")):
				paths.append(_join_path(folder, fname))
		fname = dir.get_next()
	dir.list_dir_end()
	return paths

func randomize_foreground() -> void:
	var files = _get_texture_paths_from_folder(textures_folder)
	if files.is_empty():
		push_warning("No textures found in %s" % textures_folder)
		return
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var idx = rng.randi_range(0, files.size() - 1)
	var tex = load(files[idx])
	if tex:
		$Sprite2D.texture = tex
	else:
		push_error("Failed to load texture: %s" % files[idx])
