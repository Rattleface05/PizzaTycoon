extends Control

@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var make_pizza_button = $VBoxContainer/MakePizzaButton
@onready var to_pizzeria_button = $ToPizzeriaButton
@onready var pizzas_label = $PizzasLabel

var clicks_needed: int = 5
var current_clicks: int = 0
var FloatingTextScene = preload("res://FloatingText.tscn")

@onready var money_label = $MoneyLabel
@onready var hire_junior_button = $StaffPanel/ScrollContainer/VBoxContainer/HireJuniorButton
@onready var hire_senior_button = $StaffPanel/ScrollContainer/VBoxContainer/HireSeniorButton
@onready var hire_master_button = $StaffPanel/ScrollContainer/VBoxContainer/HireMasterButton
@onready var hire_executive_button = $StaffPanel/ScrollContainer/VBoxContainer/HireExecutiveButton
@onready var hire_manager_button = $StaffPanel/ScrollContainer/VBoxContainer/HireManagerButton
@onready var hire_legend_button = $StaffPanel/ScrollContainer/VBoxContainer/HireLegendButton
@onready var hire_deity_button = $StaffPanel/ScrollContainer/VBoxContainer/HireDeityButton
@onready var to_office_button = $ToOfficeButton

const BASE_JUNIOR_COST = 50.0
const BASE_SENIOR_COST = 250.0
const BASE_MASTER_COST = 1200.0
const BASE_EXECUTIVE_COST = 6000.0
const BASE_MANAGER_COST = 35000.0
const BASE_LEGEND_COST = 200000.0
const BASE_DEITY_COST = 1250000.0


func _ready():
	make_pizza_button.pressed.connect(_on_make_pizza_pressed)
	to_pizzeria_button.pressed.connect(_on_to_pizzeria_pressed)
	to_office_button.pressed.connect(_on_to_office_pressed)
	
	hire_junior_button.pressed.connect(_on_hire_junior_pressed)
	hire_senior_button.pressed.connect(_on_hire_senior_pressed)
	hire_master_button.pressed.connect(_on_hire_master_pressed)
	hire_executive_button.pressed.connect(_on_hire_executive_pressed)
	hire_manager_button.pressed.connect(_on_hire_manager_pressed)
	hire_legend_button.pressed.connect(_on_hire_legend_pressed)
	hire_deity_button.pressed.connect(_on_hire_deity_pressed)
	
	Global.pizzas_ready_changed.connect(_on_pizzas_ready_changed)
	Global.money_changed.connect(_on_money_changed)
	Global.staff_changed.connect(_on_staff_changed)
	Global.recipes_updated.connect(_on_recipes_updated)
	
	_on_pizzas_ready_changed(Global.pizzas_ready)
	_on_money_changed(Global.money)
	_on_staff_changed()
	_on_recipes_updated()
	
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
		var price = Global.get_current_pizza_price()
		Global.add_pizza(price)
		current_clicks = 0
		# Reset bar with a slight delay so player sees it full
		tween.tween_property(progress_bar, "value", 0.0, 0.2).set_delay(0.1)
		_spawn_floating_text("Pizza Ready! ($" + str(price) + ")", make_pizza_button.global_position)

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
	pizzas_label.text = "Pizzas ready: " + str(amount) + " (Value: $" + str(Global.get_current_pizza_price()) + ")"

func _on_recipes_updated():
	_on_pizzas_ready_changed(Global.pizzas_ready)

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

func _get_executive_cost() -> float:
	return BASE_EXECUTIVE_COST * pow(1.15, Global.executive_chefs)

func _get_manager_cost() -> float:
	return BASE_MANAGER_COST * pow(1.15, Global.kitchen_managers)

func _get_legend_cost() -> float:
	return BASE_LEGEND_COST * pow(1.15, Global.pizza_legends)

func _get_deity_cost() -> float:
	return BASE_DEITY_COST * pow(1.15, Global.pizza_deities)

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

func _on_hire_executive_pressed():
	var cost = _get_executive_cost()
	if Global.money >= cost:
		Global.money -= cost
		Global.executive_chefs += 1

func _on_hire_manager_pressed():
	var cost = _get_manager_cost()
	if Global.money >= cost:
		Global.money -= cost
		Global.kitchen_managers += 1

func _on_hire_legend_pressed():
	var cost = _get_legend_cost()
	if Global.money >= cost:
		Global.money -= cost
		Global.pizza_legends += 1

func _on_hire_deity_pressed():
	var cost = _get_deity_cost()
	if Global.money >= cost:
		Global.money -= cost
		Global.pizza_deities += 1

func _update_hire_buttons():
	var j_cost = _get_junior_cost()
	var s_cost = _get_senior_cost()
	var m_cost = _get_master_cost()
	var e_cost = _get_executive_cost()
	var k_cost = _get_manager_cost()
	var l_cost = _get_legend_cost()
	var d_cost = _get_deity_cost()
	
	hire_junior_button.text = "Junior Chef: $" + str(snapped(j_cost, 0.01)) + " (+0.2/s)\nHired: " + str(Global.junior_chefs)
	hire_junior_button.disabled = Global.money < j_cost
	
	hire_senior_button.text = "Senior Chef: $" + str(snapped(s_cost, 0.01)) + " (+1.0/s)\nHired: " + str(Global.senior_chefs)
	hire_senior_button.disabled = Global.money < s_cost
	
	hire_master_button.text = "Pizza Master: $" + str(snapped(m_cost, 0.01)) + " (+5.0/s)\nHired: " + str(Global.pizza_masters)
	hire_master_button.disabled = Global.money < m_cost
	
	hire_executive_button.text = "Executive Chef: $" + str(snapped(e_cost, 0.01)) + " (+25/s)\nHired: " + str(Global.executive_chefs)
	hire_executive_button.disabled = Global.money < e_cost
	
	hire_manager_button.text = "Kitchen Manager: $" + str(snapped(k_cost, 0.01)) + " (+120/s)\nHired: " + str(Global.kitchen_managers)
	hire_manager_button.disabled = Global.money < k_cost
	
	hire_legend_button.text = "Pizza Legend: $" + str(snapped(l_cost, 0.01)) + " (+600/s)\nHired: " + str(Global.pizza_legends)
	hire_legend_button.disabled = Global.money < l_cost
	
	hire_deity_button.text = "Pizza Deity: $" + str(snapped(d_cost, 0.01)) + " (+3500/s)\nHired: " + str(Global.pizza_deities)
	hire_deity_button.disabled = Global.money < d_cost
