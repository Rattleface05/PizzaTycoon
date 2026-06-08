extends Control

@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var make_pizza_button = $VBoxContainer/MakePizzaButton
@onready var to_pizzeria_button = $ToPizzeriaButton
@onready var pizzas_label = $PizzasLabel
@onready var money_label = $MoneyLabel
@onready var to_office_button = $ToOfficeButton

var clicks_needed: int = 5
var current_clicks: int = 0
var FloatingTextScene = preload("res://FloatingText.tscn")

func _ready():
	make_pizza_button.pressed.connect(_on_make_pizza_pressed)
	to_pizzeria_button.pressed.connect(_on_to_pizzeria_pressed)
	to_office_button.pressed.connect(_on_to_office_pressed)
	
	Global.pizzas_ready_changed.connect(_on_pizzas_ready_changed)
	Global.money_changed.connect(_on_money_changed)
	Global.recipes_updated.connect(_on_recipes_updated)
	
	_on_pizzas_ready_changed(Global.pizzas_ready)
	_on_money_changed(Global.money)
	_on_recipes_updated()
	
	make_pizza_button.text = "Prepare Pizza [SPACE]"
	to_pizzeria_button.text = "Go to Pizzeria [D] ->"
	to_office_button.text = "<- Go to Office [A]"
	
	clicks_needed = max(1, 5 - Global.prestige_upgrades.get("master_baker", 0))
	progress_bar.max_value = clicks_needed
	progress_bar.value = 0

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			_on_make_pizza_pressed()
		elif event.keycode == KEY_D:
			_on_to_pizzeria_pressed()
		elif event.keycode == KEY_A:
			_on_to_office_pressed()

func _on_make_pizza_pressed():
	current_clicks += 1
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", float(current_clicks), 0.1)
	
	if current_clicks >= clicks_needed:
		var price = Global.get_current_pizza_price()
		Global.add_pizza(price)
		current_clicks = 0
		# Reset bar with a slight delay so player sees it full
		tween.tween_property(progress_bar, "value", 0.0, 0.2).set_delay(0.1)
		_spawn_floating_text("Pizza Ready! ($" + Global.format_number(price) + ")", make_pizza_button.global_position)

func _spawn_floating_text(text: String, pos: Vector2):
	if FloatingTextScene:
		var ft = FloatingTextScene.instantiate()
		ft.global_position = pos + Vector2(randf_range(0, 100), randf_range(-50, 50))
		ft.get_node("Label").text = text
		add_child(ft)

func _on_to_pizzeria_pressed():
	Global.change_scene("res://Pizzeria.tscn")

func _on_to_office_pressed():
	Global.change_scene("res://Office.tscn")

func _on_pizzas_ready_changed(amount):
	pizzas_label.text = "Pizzas ready: " + str(amount) + " (Value: $" + Global.format_number(Global.get_current_pizza_price()) + ")"

func _on_recipes_updated():
	_on_pizzas_ready_changed(Global.pizzas_ready)

func _on_money_changed(amount):
	money_label.text = "Money: $" + Global.format_number(amount)
