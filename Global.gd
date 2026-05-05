extends Node

signal money_changed(new_amount)
signal pizzas_ready_changed(new_amount)
signal level_changed(new_level)

var current_customer_texture_index: int = -1
var current_customer_order_index: int = -1

var money: float = 0.0:
	set(value):
		money = value
		money_changed.emit(money)

var pizzas_ready: int = 0:
	set(value):
		pizzas_ready = value
		pizzas_ready_changed.emit(pizzas_ready)

var ready_pizzas_prices: Array[float] = []

func add_pizza(price: float):
	ready_pizzas_prices.append(price)
	pizzas_ready = ready_pizzas_prices.size()

func sell_pizza() -> float:
	if ready_pizzas_prices.size() > 0:
		var price = ready_pizzas_prices.pop_front()
		pizzas_ready = ready_pizzas_prices.size()
		return price
	return 0.0

func get_next_pizza_price() -> float:
	if ready_pizzas_prices.size() > 0:
		return ready_pizzas_prices[0]
	return 0.0

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
