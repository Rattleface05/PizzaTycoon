extends Control

@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var make_pizza_button = $VBoxContainer/MakePizzaButton
@onready var to_pizzeria_button = $ToPizzeriaButton
@onready var pizzas_label = $PizzasLabel

var clicks_needed: int = 5
var current_clicks: int = 0
var FloatingTextScene = preload("res://FloatingText.tscn")

@onready var money_label = $MoneyLabel
@onready var hire_junior_button = $StaffPanel/VBoxContainer/HireJuniorButton
@onready var hire_senior_button = $StaffPanel/VBoxContainer/HireSeniorButton
@onready var hire_master_button = $StaffPanel/VBoxContainer/HireMasterButton
@onready var to_office_button = $ToOfficeButton

const BASE_JUNIOR_COST = 50.0
const BASE_SENIOR_COST = 200.0
const BASE_MASTER_COST = 800.0

const PIZZA_PRICE = 10.0

func _ready():
	make_pizza_button.pressed.connect(_on_make_pizza_pressed)
	to_pizzeria_button.pressed.connect(_on_to_pizzeria_pressed)
	to_office_button.pressed.connect(_on_to_office_pressed)
	
	hire_junior_button.pressed.connect(_on_hire_junior_pressed)
	hire_senior_button.pressed.connect(_on_hire_senior_pressed)
	hire_master_button.pressed.connect(_on_hire_master_pressed)
	
	Global.pizzas_ready_changed.connect(_on_pizzas_ready_changed)
	Global.money_changed.connect(_on_money_changed)
	Global.staff_changed.connect(_on_staff_changed)
	
	_on_pizzas_ready_changed(Global.pizzas_ready)
	_on_money_changed(Global.money)
	_on_staff_changed()
	
	make_pizza_button.text = "Prepare Pizza [SPACE]"
	to_pizzeria_button.text = "Go to Pizzeria [D] ->"
	to_office_button.text = "<- Go to Office [A]"
	
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
		Global.add_pizza(PIZZA_PRICE)
		current_clicks = 0
		# Reset bar with a slight delay so player sees it full
		tween.tween_property(progress_bar, "value", 0.0, 0.2).set_delay(0.1)
		_spawn_floating_text("Pizza Ready! ($" + str(PIZZA_PRICE) + ")", make_pizza_button.global_position)

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
	pizzas_label.text = "Pizzas ready: " + str(amount)

func _on_money_changed(amount):
	money_label.text = "Money: $" + str(snapped(amount, 0.01))
	_update_hire_buttons()

func _on_staff_changed():
	_update_hire_buttons()

func _get_junior_cost() -> float:
	return BASE_JUNIOR_COST * pow(1.15, Global.junior_chefs)

func _get_senior_cost() -> float:
	return BASE_SENIOR_COST * pow(1.15, Global.senior_chefs)

func _get_master_cost() -> float:
	return BASE_MASTER_COST * pow(1.15, Global.pizza_masters)

func _on_hire_junior_pressed():
	var cost = _get_junior_cost()
	if Global.money >= cost:
		Global.money -= cost
		Global.junior_chefs += 1

func _on_hire_senior_pressed():
	var cost = _get_senior_cost()
	if Global.money >= cost:
		Global.money -= cost
		Global.senior_chefs += 1

func _on_hire_master_pressed():
	var cost = _get_master_cost()
	if Global.money >= cost:
		Global.money -= cost
		Global.pizza_masters += 1

func _update_hire_buttons():
	var j_cost = _get_junior_cost()
	var s_cost = _get_senior_cost()
	var m_cost = _get_master_cost()
	
	hire_junior_button.text = "Junior Chef: $" + str(snapped(j_cost, 0.01)) + " (+0.2/s)\nHired: " + str(Global.junior_chefs)
	hire_junior_button.disabled = Global.money < j_cost
	
	hire_senior_button.text = "Senior Chef: $" + str(snapped(s_cost, 0.01)) + " (+1.0/s)\nHired: " + str(Global.senior_chefs)
	hire_senior_button.disabled = Global.money < s_cost
	
	hire_master_button.text = "Pizza Master: $" + str(snapped(m_cost, 0.01)) + " (+5.0/s)\nHired: " + str(Global.pizza_masters)
	hire_master_button.disabled = Global.money < m_cost
