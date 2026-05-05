extends Control

@onready var background = $Background
@onready var money_label = $HUD/MoneyLabel
@onready var pizzas_label = $HUD/PizzasLabel
@onready var sell_button = $VBoxContainer/SellButton
@onready var upgrade_button = $VBoxContainer/UpgradeButton
@onready var to_kitchen_button = $ToKitchenButton

const PIZZA_PRICE = 10.0
const UPGRADE_PRICES = [20.0, 100.0, 500.0]
var LEVEL_TEXTURES = [
	preload("res://textures/backgrounds/tables_poor.jpg"),
	preload("res://textures/backgrounds/tables_normal.jpg"),
	preload("res://textures/backgrounds/tables_fancy.jpg"),
	preload("res://textures/backgrounds/tables_extravagant.jpg")
]

var FloatingTextScene = preload("res://FloatingText.tscn")

var auto_sell_timer: float = 0.0
const AUTO_SELL_DELAY: float = 0.3
const AUTO_SELL_INTERVAL: float = 0.1
var is_selling_held: bool = false

func _ready():
	sell_button.pressed.connect(_on_sell_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	to_kitchen_button.pressed.connect(_on_to_kitchen_pressed)
	
	Global.money_changed.connect(_on_money_changed)
	Global.pizzas_ready_changed.connect(_on_pizzas_ready_changed)
	Global.level_changed.connect(_on_level_changed)
	
	# Initial UI updates
	sell_button.text = "Sell Pizza [SPACE] ($10)"
	to_kitchen_button.text = "<- Go to Kitchen [A]"
	
	_on_money_changed(Global.money)
	_on_pizzas_ready_changed(Global.pizzas_ready)
	_on_level_changed(Global.upgrade_level)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			if not sell_button.disabled:
				_on_sell_pressed()
		elif event.keycode == KEY_A:
			_on_to_kitchen_pressed()
		elif event.keycode == KEY_E:
			if not upgrade_button.disabled:
				_on_upgrade_pressed()

func _process(delta):
	var currently_held = Input.is_key_pressed(KEY_SPACE) or sell_button.is_pressed()
	
	if currently_held:
		if not is_selling_held:
			is_selling_held = true
			auto_sell_timer = AUTO_SELL_DELAY
		else:
			auto_sell_timer -= delta
			if auto_sell_timer <= 0.0:
				if not sell_button.disabled:
					_on_sell_pressed()
				auto_sell_timer = AUTO_SELL_INTERVAL
	else:
		is_selling_held = false

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
	Global.change_scene("res://Kitchen.tscn")

func _on_money_changed(amount):
	money_label.text = "Money: $" + str(amount)
	_update_buttons()

func _on_pizzas_ready_changed(amount):
	pizzas_label.text = "Pizzas to sell: " + str(amount)
	_update_buttons()

func _on_level_changed(level):
	# Update visual background
	if level < LEVEL_TEXTURES.size():
		background.texture = LEVEL_TEXTURES[level]
		background.modulate = Color(1, 1, 1, 1)
	_update_buttons()

func _update_buttons():
	sell_button.disabled = Global.pizzas_ready <= 0
	
	if Global.upgrade_level < UPGRADE_PRICES.size():
		var cost = UPGRADE_PRICES[Global.upgrade_level]
		upgrade_button.text = "Upgrade Pizzeria [E] ($" + str(cost) + ")"
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
