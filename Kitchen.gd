extends Control

@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var make_pizza_button = $VBoxContainer/MakePizzaButton
@onready var to_pizzeria_button = $ToPizzeriaButton
@onready var pizzas_label = $PizzasLabel

var clicks_needed: int = 5
var current_clicks: int = 0
var FloatingTextScene = preload("res://FloatingText.tscn")

const BASE_PRICE = 2.0

const CHEESE_TYPES = {
	"Mozzarella": 2.0,
	"Cheddar": 3.0,
	"Gorgonzola": 4.0,
	"Parmesan": 5.0
}

const TOPPINGS = {
	"Pepperoni": 2.0,
	"Olives": 1.0,
	"Bacon": 3.0,
	"Pineapple": 2.0,
	"Anchovies": 3.0,
	"Mushrooms": 1.0,
	"Sausages": 2.0
}

const SAUCES = {
	"Tomato Sauce": 1.0,
	"Pesto": 2.0,
	"Ranch": 2.0,
	"Spicy": 1.0
}

var ingredients_popup: PopupPanel
var cheese_option: OptionButton
var toppings_container: VBoxContainer
var sauces_container: VBoxContainer
var toppings_checkboxes: Array = []
var sauces_checkboxes: Array = []

func _ready():
	make_pizza_button.pressed.connect(_on_make_pizza_pressed)
	to_pizzeria_button.pressed.connect(_on_to_pizzeria_pressed)
	Global.pizzas_ready_changed.connect(_on_pizzas_ready_changed)
	_on_pizzas_ready_changed(Global.pizzas_ready)
	
	make_pizza_button.text = "Prepare Pizza [SPACE]"
	to_pizzeria_button.text = "Go to Pizzeria [D] ->"
	
	progress_bar.max_value = clicks_needed
	progress_bar.value = 0
	
	_setup_ingredients_ui()

func _setup_ingredients_ui():
	var btn_ing = Button.new()
	btn_ing.text = "Select Ingredients"
	btn_ing.position = Vector2(32, 150)
	btn_ing.pressed.connect(func(): ingredients_popup.popup_centered())
	add_child(btn_ing)
	
	ingredients_popup = PopupPanel.new()
	ingredients_popup.size = Vector2(400, 500)
	add_child(ingredients_popup)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	ingredients_popup.add_child(vbox)
	
	var lbl_cheese = Label.new()
	lbl_cheese.text = "Cheese (Select 1)"
	vbox.add_child(lbl_cheese)
	cheese_option = OptionButton.new()
	for c in CHEESE_TYPES.keys():
		cheese_option.add_item(c + " ($" + str(CHEESE_TYPES[c]) + ")")
	vbox.add_child(cheese_option)
	
	var lbl_top = Label.new()
	lbl_top.text = "Toppings (Max 5)"
	vbox.add_child(lbl_top)
	toppings_container = VBoxContainer.new()
	vbox.add_child(toppings_container)
	for t in TOPPINGS.keys():
		var cb = CheckBox.new()
		cb.text = t + " ($" + str(TOPPINGS[t]) + ")"
		cb.toggled.connect(func(toggled_on): _on_topping_toggled(cb, toggled_on))
		cb.set_meta("ingredient_name", t)
		toppings_container.add_child(cb)
		toppings_checkboxes.append(cb)
		
	var lbl_sauce = Label.new()
	lbl_sauce.text = "Sauces (Max 2)"
	vbox.add_child(lbl_sauce)
	sauces_container = VBoxContainer.new()
	vbox.add_child(sauces_container)
	for s in SAUCES.keys():
		var cb = CheckBox.new()
		cb.text = s + " ($" + str(SAUCES[s]) + ")"
		cb.toggled.connect(func(toggled_on): _on_sauce_toggled(cb, toggled_on))
		cb.set_meta("ingredient_name", s)
		sauces_container.add_child(cb)
		sauces_checkboxes.append(cb)

func _on_topping_toggled(cb: CheckBox, toggled_on: bool):
	if toggled_on:
		var count = 0
		for c in toppings_checkboxes:
			if c.button_pressed:
				count += 1
		if count > 5:
			cb.button_pressed = false

func _on_sauce_toggled(cb: CheckBox, toggled_on: bool):
	if toggled_on:
		var count = 0
		for c in sauces_checkboxes:
			if c.button_pressed:
				count += 1
		if count > 2:
			cb.button_pressed = false

func _reset_ingredients():
	cheese_option.selected = 0
	for cb in toppings_checkboxes:
		cb.button_pressed = false
	for cb in sauces_checkboxes:
		cb.button_pressed = false

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			_on_make_pizza_pressed()
		elif event.keycode == KEY_D:
			_on_to_pizzeria_pressed()

func _on_make_pizza_pressed():
	current_clicks += 1
	var tween = create_tween()
	tween.tween_property(progress_bar, "value", float(current_clicks), 0.1)
	
	if current_clicks >= clicks_needed:
		var final_price = BASE_PRICE
		var selected_cheese = CHEESE_TYPES.keys()[cheese_option.selected]
		final_price += CHEESE_TYPES[selected_cheese]
		for cb in toppings_checkboxes:
			if cb.button_pressed:
				final_price += TOPPINGS[cb.get_meta("ingredient_name")]
		for cb in sauces_checkboxes:
			if cb.button_pressed:
				final_price += SAUCES[cb.get_meta("ingredient_name")]
				
		Global.add_pizza(final_price)
		
		current_clicks = 0
		# Reset bar with a slight delay so player sees it full
		tween.tween_property(progress_bar, "value", 0.0, 0.2).set_delay(0.1)
		_spawn_floating_text("Pizza Ready! ($" + str(final_price) + ")", make_pizza_button.global_position)
		_reset_ingredients()

func _spawn_floating_text(text: String, pos: Vector2):
	if FloatingTextScene:
		var ft = FloatingTextScene.instantiate()
		ft.global_position = pos + Vector2(randf_range(0, 100), randf_range(-50, 50))
		ft.get_node("Label").text = text
		add_child(ft)

func _on_to_pizzeria_pressed():
	Global.change_scene("res://Pizzeria.tscn")

func _on_pizzas_ready_changed(amount):
	pizzas_label.text = "Pizzas ready: " + str(amount)
