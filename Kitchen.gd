extends Control

@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var make_pizza_button = $VBoxContainer/MakePizzaButton
@onready var to_pizzeria_button = $ToPizzeriaButton
@onready var pizzas_label = $PizzasLabel

var clicks_needed: int = 5
var current_clicks: int = 0
var FloatingTextScene = preload("res://FloatingText.tscn")

func _ready():
	make_pizza_button.pressed.connect(_on_make_pizza_pressed)
	to_pizzeria_button.pressed.connect(_on_to_pizzeria_pressed)
	Global.pizzas_ready_changed.connect(_on_pizzas_ready_changed)
	_on_pizzas_ready_changed(Global.pizzas_ready)
	
	progress_bar.max_value = clicks_needed
	progress_bar.value = 0

func _on_make_pizza_pressed():
	current_clicks += 1
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", float(current_clicks), 0.1)
	
	if current_clicks >= clicks_needed:
		Global.pizzas_ready += 1
		current_clicks = 0
		# Reset bar with a slight delay so player sees it full
		tween.tween_property(progress_bar, "value", 0.0, 0.2).set_delay(0.1)
		_spawn_floating_text("Pizza Gata!", make_pizza_button.global_position)

func _spawn_floating_text(text: String, pos: Vector2):
	if FloatingTextScene:
		var ft = FloatingTextScene.instantiate()
		ft.global_position = pos + Vector2(randf_range(0, 100), randf_range(-50, 50))
		ft.get_node("Label").text = text
		add_child(ft)

func _on_to_pizzeria_pressed():
	get_tree().change_scene_to_file("res://Pizzeria.tscn")

func _on_pizzas_ready_changed(amount):
	pizzas_label.text = "Pizzas ready: " + str(amount)
