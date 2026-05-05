extends Node

signal money_changed(new_amount)
signal pizzas_ready_changed(new_amount)
signal level_changed(new_level)

var money: float = 0.0:
	set(value):
		money = value
		money_changed.emit(money)

var pizzas_ready: int = 0:
	set(value):
		pizzas_ready = value
		pizzas_ready_changed.emit(pizzas_ready)

var upgrade_level: int = 0:
	set(value):
		upgrade_level = value
		level_changed.emit(upgrade_level)

var transition_layer: CanvasLayer
var color_rect: ColorRect
var is_transitioning: bool = false

func _ready():
	transition_layer = CanvasLayer.new()
	transition_layer.layer = 100
	
	color_rect = ColorRect.new()
	color_rect.color = Color(0, 0, 0, 0)
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	transition_layer.add_child(color_rect)
	add_child(transition_layer)

func change_scene(path: String):
	if is_transitioning:
		return
	is_transitioning = true
	
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, 0.3)
	await tween.finished
	
	get_tree().change_scene_to_file(path)
	
	var tween_out = create_tween()
	tween_out.tween_property(color_rect, "color:a", 0.0, 0.3)
	await tween_out.finished
	
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false
