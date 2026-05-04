extends Control

@onready var background = $ColorRect
@onready var money_label = $HUD/MoneyLabel
@onready var pizzas_label = $HUD/PizzasLabel
@onready var sell_button = $VBoxContainer/SellButton
@onready var upgrade_button = $VBoxContainer/UpgradeButton
@onready var to_kitchen_button = $ToKitchenButton

const PIZZA_PRICE = 10.0
const UPGRADE_PRICES = [100.0, 500.0]
const LEVEL_COLORS = [
	Color(0.3, 0.3, 0.3, 1), # Level 0: Dull gray
	Color(0.6, 0.5, 0.4, 1), # Level 1: Wood-like
	Color(0.2, 0.6, 0.8, 1)  # Level 2: Bright Blue
]

var FloatingTextScene = preload("res://FloatingText.tscn")

func _ready():
	sell_button.pressed.connect(_on_sell_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	to_kitchen_button.pressed.connect(_on_to_kitchen_pressed)
	
	Global.money_changed.connect(_on_money_changed)
	Global.pizzas_ready_changed.connect(_on_pizzas_ready_changed)
	Global.level_changed.connect(_on_level_changed)
	
	# Initial UI updates
	_on_money_changed(Global.money)
	_on_pizzas_ready_changed(Global.pizzas_ready)
	_on_level_changed(Global.upgrade_level)

func _on_sell_pressed():
	if Global.pizzas_ready > 0:
		Global.pizzas_ready -= 1
		Global.money += PIZZA_PRICE
		_spawn_floating_text("+$" + str(PIZZA_PRICE), sell_button.global_position)

func _on_upgrade_pressed():
	if Global.upgrade_level < UPGRADE_PRICES.size():
		var cost = UPGRADE_PRICES[Global.upgrade_level]
		if Global.money >= cost:
			Global.money -= cost
			Global.upgrade_level += 1

func _on_to_kitchen_pressed():
	get_tree().change_scene_to_file("res://Kitchen.tscn")

func _on_money_changed(amount):
	money_label.text = "Money: $" + str(amount)
	_update_buttons()

func _on_pizzas_ready_changed(amount):
	pizzas_label.text = "Pizzas to sell: " + str(amount)
	_update_buttons()

func _on_level_changed(level):
	# Update visual background
	if level < LEVEL_COLORS.size():
		background.color = LEVEL_COLORS[level]
	_update_buttons()

func _update_buttons():
	sell_button.disabled = Global.pizzas_ready <= 0
	
	if Global.upgrade_level < UPGRADE_PRICES.size():
		var cost = UPGRADE_PRICES[Global.upgrade_level]
		upgrade_button.text = "Upgrade Pizzeria ($" + str(cost) + ")"
		upgrade_button.disabled = Global.money < cost
	else:
		upgrade_button.text = "MAX LEVEL REACHED"
		upgrade_button.disabled = true

func _spawn_floating_text(text: String, pos: Vector2):
	if FloatingTextScene:
		var ft = FloatingTextScene.instantiate()
		ft.global_position = pos + Vector2(randf_range(0, 100), randf_range(-50, 50))
		ft.get_node("Label").text = text
		add_child(ft)
