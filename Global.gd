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

func add_pizza(price: float):
	pizzas_ready += 1

func sell_pizza() -> float:
	if pizzas_ready > 0:
		pizzas_ready -= 1
		return get_current_pizza_price()
	return 0.0

func get_next_pizza_price() -> float:
	return get_current_pizza_price()

func format_number(value: float) -> String:
	if value < 1000.0:
		return str(snapped(value, 0.01))
	
	var suffixes = ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]
	var tier = floor(log(value) / log(1000.0))
	if tier >= suffixes.size():
		return "%.2e" % value
		
	var scale = pow(1000.0, tier)
	var formatted = value / scale
	return "%.2f%s" % [formatted, suffixes[tier]]

var upgrade_level: int = 0:
	set(value):
		upgrade_level = value
		level_changed.emit(upgrade_level)

var transition_layer: CanvasLayer
var color_rect: ColorRect
var is_transitioning: bool = false

func _ready():
	# Create canvas layer for transition
	transition_layer = CanvasLayer.new()
	transition_layer.layer = 100 # Draw above everything
	add_child(transition_layer)
	
	color_rect = ColorRect.new()
	color_rect.color = Color(0, 0, 0, 0) # Start transparent
	color_rect.anchors_preset = Control.PRESET_FULL_RECT
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition_layer.add_child(color_rect)
	
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false

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
	{ "name": "Junior Chef", "base_cost": 100.0, "cook_rate": 0.2 },
	{ "name": "Senior Chef", "base_cost": 600.0, "cook_rate": 1.0 },
	{ "name": "Pizza Master", "base_cost": 4000.0, "cook_rate": 6.0 },
	{ "name": "Executive Chef", "base_cost": 30000.0, "cook_rate": 40.0 },
	{ "name": "Kitchen Manager", "base_cost": 250000.0, "cook_rate": 300.0 },
	{ "name": "Pizza Legend", "base_cost": 2000000.0, "cook_rate": 2500.0 },
	{ "name": "Pizza Deity", "base_cost": 20000000.0, "cook_rate": 22000.0 },
	{ "name": "Cosmic Cook-Bot", "base_cost": 250000000.0, "cook_rate": 200000.0 },
	{ "name": "Chef Singularity", "base_cost": 3500000000.0, "cook_rate": 2000000.0 }
]

var hired_chefs: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]

var _auto_cook_progress: float = 0.0
var _auto_sell_progress: float = 0.0

signal recipes_updated()
signal cashiers_updated()

const RECIPES = [
	{ "name": "Margherita", "buy_cost": 0.0, "pizza_value": 15.0 },
	{ "name": "Pepperoni", "buy_cost": 400.0, "pizza_value": 60.0 },
	{ "name": "Quattro Formaggi", "buy_cost": 3000.0, "pizza_value": 300.0 },
	{ "name": "Carnivora", "buy_cost": 25000.0, "pizza_value": 1800.0 },
	{ "name": "Supreme Master", "buy_cost": 200000.0, "pizza_value": 12000.0 },
	{ "name": "Galactic Pizza", "buy_cost": 2000000.0, "pizza_value": 90000.0 },
	{ "name": "Pizza Singularity", "buy_cost": 25000000.0, "pizza_value": 800000.0 },
	{ "name": "Pizza Omega", "buy_cost": 350000000.0, "pizza_value": 9000000.0 },
	{ "name": "Pizza Universe", "buy_cost": 5000000000.0, "pizza_value": 110000000.0 },
	{ "name": "Pizza Multiverse", "buy_cost": 80000000000.0, "pizza_value": 1500000000.0 }
]

const CASHIERS = [
	{ "name": "Junior Cashier", "base_cost": 150.0, "sell_rate": 0.4 },
	{ "name": "Senior Cashier", "base_cost": 900.0, "sell_rate": 2.0 },
	{ "name": "Selling Machine", "base_cost": 6000.0, "sell_rate": 12.0 },
	{ "name": "Cashier Overlord", "base_cost": 45000.0, "sell_rate": 80.0 },
	{ "name": "Hyper-Vender", "base_cost": 350000.0, "sell_rate": 600.0 },
	{ "name": "Selling Singularity", "base_cost": 3000000.0, "sell_rate": 5000.0 },
	{ "name": "Cosmic Merchant", "base_cost": 25000000.0, "sell_rate": 45000.0 },
	{ "name": "Selling Portal", "base_cost": 300000000.0, "sell_rate": 400000.0 },
	{ "name": "Mercenary of Sales", "base_cost": 4500000000.0, "sell_rate": 4000000.0 }
]

var hired_cashiers: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
var unlocked_recipes: Array[int] = [0]
var active_recipe_index: int = 0:
	set(value):
		active_recipe_index = value
		recipes_updated.emit()

func get_current_pizza_price() -> float:
	if active_recipe_index >= 0 and active_recipe_index < RECIPES.size():
		return RECIPES[active_recipe_index]["pizza_value"]
	return 15.0

func _process(delta):
	var total_rate = 0.0
	for i in range(CHEFS.size()):
		total_rate += hired_chefs[i] * CHEFS[i]["cook_rate"]
	
	if total_rate > 0.0:
		_auto_cook_progress += total_rate * delta
		if _auto_cook_progress >= 1.0:
			var completed_pizzas = floor(_auto_cook_progress)
			pizzas_ready += int(completed_pizzas)
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
