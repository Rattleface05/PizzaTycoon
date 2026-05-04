extends Control

@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var make_pizza_button = $VBoxContainer/MakePizzaButton
@onready var to_pizzeria_button = $ToPizzeriaButton
@onready var pizzas_label = $PizzasLabel

var clicks_needed: int = 5
var current_clicks: int = 0

func _ready():
	make_pizza_button.pressed.connect(_on_make_pizza_pressed)
	to_pizzeria_button.pressed.connect(_on_to_pizzeria_pressed)
	Global.pizzas_ready_changed.connect(_on_pizzas_ready_changed)
	_on_pizzas_ready_changed(Global.pizzas_ready)
	
	progress_bar.max_value = clicks_needed
	progress_bar.value = 0

func _on_make_pizza_pressed():
	current_clicks += 1
	progress_bar.value = current_clicks
	if current_clicks >= clicks_needed:
		Global.pizzas_ready += 1
		current_clicks = 0
		progress_bar.value = 0

func _on_to_pizzeria_pressed():
	get_tree().change_scene_to_file("res://Pizzeria.tscn")

func _on_pizzas_ready_changed(amount):
	pizzas_label.text = "Pizzas ready: " + str(amount)
