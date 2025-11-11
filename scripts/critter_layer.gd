extends Control

signal critters_finished

const CRITTER = preload("res://scenes/critter.tscn")
@export var spawn_delay: float = 0.05
var animation_duration: float = 2.0

func animate_critters(duration: float, count: int, target_rect: Rect2, critter_size: float):
	animation_duration = duration
	
	for child in get_children():
		child.queue_free()
	
	# Spawn from random edges
	for i in range(count):
		await get_tree().create_timer(spawn_delay).timeout
		spawn_critter(target_rect, critter_size)
	
	# Wait for all critters to spawn
	await get_tree().create_timer(animation_duration).timeout
	critters_finished.emit()

func spawn_critter(target_rect: Rect2, critter_size: float):
	var critter = CRITTER.instantiate()
	var tile_size_setting = Globals.tile_size
	var custom_critter_size: float = critter_size
	add_child(critter)
	
	# Pick a random edge
	var edge = randi() % 4
	var start_pos = get_spawn_position(edge)
	var end_pos = get_random_point_in_rect(target_rect)
	var direction = (end_pos - start_pos).angle()
	
	if critter_size == 0:
		custom_critter_size = Globals.TILE_SIZES[tile_size_setting]
	critter.scale = Vector2(custom_critter_size/256, custom_critter_size/256)
	critter.position = start_pos
	critter.rotation = direction
	
	# Animate critter to point
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(critter, "position", end_pos, animation_duration)
	tween.tween_callback(critter.hide_critter)

func get_spawn_position(edge: int) -> Vector2:
	var margin: float = 50.0
	match edge:
		0: # Top Edge
			return Vector2(randf() * size.x, - margin)
		1: # Right Edge
			return Vector2(size.x + margin, randf() * size.y)
		3: # Bottom Edge
			return Vector2(randf() * size.x, size.y + margin)
		_: # Left Edge
			return Vector2(-margin, randf() * size.y)

func get_random_point_in_rect(rect: Rect2) -> Vector2:
	return Vector2(
		# Pick a random point within the grid (reduced size for margin)
		rect.position.x + randf() * (rect.size.x * 0.8),
		rect.position.y + randf() * (rect.size.y * 0.8),
	)
