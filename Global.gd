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

signal chefs_updated()

const CHEFS = [
	{ "name": "Junior Chef", "base_cost": 50.0, "cook_rate": 0.2 },
	{ "name": "Senior Chef", "base_cost": 250.0, "cook_rate": 1.0 },
	{ "name": "Pizza Master", "base_cost": 1200.0, "cook_rate": 5.0 },
	{ "name": "Executive Chef", "base_cost": 6000.0, "cook_rate": 25.0 },
	{ "name": "Kitchen Manager", "base_cost": 35000.0, "cook_rate": 120.0 },
	{ "name": "Pizza Legend", "base_cost": 200000.0, "cook_rate": 600.0 },
	{ "name": "Pizza Deity", "base_cost": 1250000.0, "cook_rate": 3500.0 }
]

var hired_chefs: Array[int] = [0, 0, 0, 0, 0, 0, 0]

var _auto_cook_progress: float = 0.0
var _auto_sell_progress: float = 0.0

signal recipes_updated()
signal cashiers_updated()

const RECIPES = [
	{ "name": "Margherita", "buy_cost": 0.0, "pizza_value": 10.0 },
	{ "name": "Pepperoni", "buy_cost": 200.0, "pizza_value": 35.0 },
	{ "name": "Quattro Formaggi", "buy_cost": 1200.0, "pizza_value": 120.0 },
	{ "name": "Carnivora", "buy_cost": 8000.0, "pizza_value": 450.0 },
	{ "name": "Supreme Master", "buy_cost": 50000.0, "pizza_value": 2000.0 },
	{ "name": "Galactic Pizza", "buy_cost": 300000.0, "pizza_value": 10000.0 },
	{ "name": "Pizza Singularity", "buy_cost": 2000000.0, "pizza_value": 60000.0 }
]

const CASHIERS = [
	{ "name": "Junior Cashier", "base_cost": 80.0, "sell_rate": 0.4 },
	{ "name": "Senior Cashier", "base_cost": 400.0, "sell_rate": 2.0 },
	{ "name": "Selling Machine", "base_cost": 2000.0, "sell_rate": 10.0 },
	{ "name": "Cashier Overlord", "base_cost": 10000.0, "sell_rate": 50.0 },
	{ "name": "Hyper-Vender", "base_cost": 60000.0, "sell_rate": 250.0 },
	{ "name": "Selling Singularity", "base_cost": 400000.0, "sell_rate": 1200.0 },
	{ "name": "Cosmic Merchant", "base_cost": 2500000.0, "sell_rate": 6000.0 }
]

var hired_cashiers: Array[int] = [0, 0, 0, 0, 0, 0, 0]
var unlocked_recipes: Array[int] = [0]
var active_recipe_index: int = 0:
	set(value):
		active_recipe_index = value
		recipes_updated.emit()

func get_current_pizza_price() -> float:
	if active_recipe_index >= 0 and active_recipe_index < RECIPES.size():
		return RECIPES[active_recipe_index]["pizza_value"]
	return 10.0

func _process(delta):
	var total_rate = 0.0
	for i in range(CHEFS.size()):
		total_rate += hired_chefs[i] * CHEFS[i]["cook_rate"]
	
	if total_rate > 0.0:
		_auto_cook_progress += total_rate * delta
		if _auto_cook_progress >= 1.0:
			var completed_pizzas = floor(_auto_cook_progress)
			for i in range(int(completed_pizzas)):
				add_pizza(get_current_pizza_price())
			_auto_cook_progress -= completed_pizzas
			
	# Auto-sell logic
	var total_sell_rate = 0.0
	for i in range(CASHIERS.size()):
		total_sell_rate += hired_cashiers[i] * CASHIERS[i]["sell_rate"]
		
	if total_sell_rate > 0.0 and pizzas_ready > 0:
		_auto_sell_progress += total_sell_rate * delta
		if _auto_sell_progress >= 1.0:
			var to_sell = min(floor(_auto_sell_progress), pizzas_ready)
			if to_sell > 0:
				pizzas_ready -= int(to_sell)
				money += to_sell * get_current_pizza_price()
			_auto_sell_progress -= floor(_auto_sell_progress)
