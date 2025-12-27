extends AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade_music_in()

func _on_finished() -> void:
	var timer = get_tree().create_timer(randf_range(5, 20))
	await timer.timeout
	fade_music_in()

func fade_music_in() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	volume_linear = 0.25
	play()
	tween.tween_property(self, "volume_linear", Globals.music_vol, 1)
