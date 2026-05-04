extends Node2D

func _ready():
	var tween = create_tween()
	tween.tween_property(self, "position", position + Vector2(0, -100), 1.0)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)
