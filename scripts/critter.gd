extends Sprite2D

@export var textures: Array[Texture2D] = []
@export var rotation_speed: float = 0.25

func _ready():
	if textures.size() > 0:
		texture = textures[randi() % textures.size()]
	scale = Vector2(0.2, 0.2)

func hide_critter():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(queue_free)
