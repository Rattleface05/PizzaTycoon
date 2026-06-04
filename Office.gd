extends Control

@onready var to_kitchen_button = $ToKitchenButton
@onready var recipe_list = $LaptopScreen/MarginContainer/VBoxContainer/ScrollContainer/RecipeList
@onready var money_label = $LaptopScreen/MarginContainer/VBoxContainer/Header/MoneyLabel
@onready var recipes_tab_button = $LaptopScreen/MarginContainer/VBoxContainer/TabBar/RecipesTabButton
@onready var chefs_tab_button = $LaptopScreen/MarginContainer/VBoxContainer/TabBar/ChefsTabButton
@onready var cashiers_tab_button = $LaptopScreen/MarginContainer/VBoxContainer/TabBar/CashiersTabButton

var style_normal: StyleBoxFlat
var style_hover: StyleBoxFlat
var style_pressed: StyleBoxFlat
var style_tab_active: StyleBoxFlat
var style_tab_inactive: StyleBoxFlat

var active_tab: int = 0 # 0 = Recipes, 1 = Chefs, 2 = Cashiers
var action_buttons_data: Array = [] # Dictionary list: { "button": Button, "cost": float, "type": String, "index": int }

func _ready():
	to_kitchen_button.pressed.connect(_on_to_kitchen_pressed)
	recipes_tab_button.pressed.connect(func(): _on_tab_changed(0))
	chefs_tab_button.pressed.connect(func(): _on_tab_changed(1))
	cashiers_tab_button.pressed.connect(func(): _on_tab_changed(2))
	
	# Connect global updates
	Global.money_changed.connect(_on_money_changed)
	Global.recipes_updated.connect(_update_recipe_list)
	Global.chefs_updated.connect(_update_recipe_list)
	Global.cashiers_updated.connect(_update_recipe_list)
	
	# Build styles
	style_normal = _create_btn_style(Color(0.18, 0.18, 0.24, 0.9))
	style_hover = _create_btn_style(Color(0.28, 0.28, 0.36, 0.95))
	style_pressed = _create_btn_style(Color(0.12, 0.12, 0.16, 0.9))
	style_tab_active = _create_btn_style(Color(0.45, 0.2, 0.2, 0.9))
	style_tab_inactive = _create_btn_style(Color(0.12, 0.12, 0.16, 0.7))
	
	# Restore active tab index
	active_tab = Global.active_office_tab
	
	# Initial updates
	_update_tab_buttons_appearance()
	_on_money_changed(Global.money)
	_update_recipe_list()

func _create_btn_style(bg_color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(1, 1, 1, 0.15)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	return style

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_D:
			_on_to_kitchen_pressed()

func _on_to_kitchen_pressed():
	Global.change_scene("res://Kitchen.tscn")

func _on_money_changed(amount):
	money_label.text = "Cash: $" + Global.format_number(amount) + " "
	
	# Update only the disabled state of the active buttons to avoid rebuilding the list
	for data in action_buttons_data:
		var btn = data["button"]
		if is_instance_valid(btn):
			if data["type"] == "recipe":
				var recipe_index = data["index"]
				var is_active = (Global.active_recipe_index == recipe_index)
				var is_unlocked = Global.unlocked_recipes.has(recipe_index)
				if is_active:
					btn.disabled = true
				elif is_unlocked:
					btn.disabled = false
				else:
					btn.disabled = (amount < data["cost"])
			else:
				btn.disabled = (amount < data["cost"])

func _on_tab_changed(tab_index: int):
	active_tab = tab_index
	Global.active_office_tab = tab_index
	_update_tab_buttons_appearance()
	_update_recipe_list()

func _update_tab_buttons_appearance():
	# Reset styles for all three buttons first
	recipes_tab_button.add_theme_stylebox_override("normal", style_tab_inactive)
	recipes_tab_button.add_theme_stylebox_override("hover", style_hover)
	recipes_tab_button.add_theme_stylebox_override("pressed", style_pressed)
	
	chefs_tab_button.add_theme_stylebox_override("normal", style_tab_inactive)
	chefs_tab_button.add_theme_stylebox_override("hover", style_hover)
	chefs_tab_button.add_theme_stylebox_override("pressed", style_pressed)
	
	cashiers_tab_button.add_theme_stylebox_override("normal", style_tab_inactive)
	cashiers_tab_button.add_theme_stylebox_override("hover", style_hover)
	cashiers_tab_button.add_theme_stylebox_override("pressed", style_pressed)
	
	# Override active tab style
	if active_tab == 0:
		recipes_tab_button.add_theme_stylebox_override("normal", style_tab_active)
		recipes_tab_button.add_theme_stylebox_override("hover", style_tab_active)
		recipes_tab_button.add_theme_stylebox_override("pressed", style_tab_active)
	elif active_tab == 1:
		chefs_tab_button.add_theme_stylebox_override("normal", style_tab_active)
		chefs_tab_button.add_theme_stylebox_override("hover", style_tab_active)
		chefs_tab_button.add_theme_stylebox_override("pressed", style_tab_active)
	elif active_tab == 2:
		cashiers_tab_button.add_theme_stylebox_override("normal", style_tab_active)
		cashiers_tab_button.add_theme_stylebox_override("hover", style_tab_active)
		cashiers_tab_button.add_theme_stylebox_override("pressed", style_tab_active)

func _update_recipe_list():
	if not recipe_list:
		return
		
	# Clear old rows
	for child in recipe_list.get_children():
		child.queue_free()
		
	action_buttons_data.clear()
		
	if active_tab == 0:
		# Build new recipe rows
		for i in range(Global.RECIPES.size()):
			var recipe = Global.RECIPES[i]
			var is_unlocked = Global.unlocked_recipes.has(i)
			var is_active = (Global.active_recipe_index == i)
			
			var row = HBoxContainer.new()
			row.add_theme_constant_override("separation", 15)
			
			# Info VBox
			var info_vbox = VBoxContainer.new()
			info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var name_lbl = Label.new()
			name_lbl.text = recipe["name"]
			name_lbl.add_theme_font_size_override("font_size", 16)
			name_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
			name_lbl.add_theme_constant_override("outline_size", 4)
			info_vbox.add_child(name_lbl)
			
			var desc_lbl = Label.new()
			desc_lbl.text = "Pizza Value: $" + Global.format_number(recipe["pizza_value"])
			desc_lbl.add_theme_font_size_override("font_size", 12)
			desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
			info_vbox.add_child(desc_lbl)
			
			row.add_child(info_vbox)
			
			# Action Button
			var action_btn = Button.new()
			action_btn.custom_minimum_size = Vector2(160, 45)
			action_btn.add_theme_font_size_override("font_size", 13)
			
			action_btn.add_theme_stylebox_override("normal", style_normal)
			action_btn.add_theme_stylebox_override("hover", style_hover)
			action_btn.add_theme_stylebox_override("pressed", style_pressed)
			
			if is_active:
				action_btn.text = "Active"
				action_btn.disabled = true
			elif is_unlocked:
				action_btn.text = "Activate"
				action_btn.pressed.connect(func(): _on_activate_recipe(i))
			else:
				action_btn.text = "Buy: $" + Global.format_number(recipe["buy_cost"])
				action_btn.disabled = (Global.money < recipe["buy_cost"])
				action_btn.pressed.connect(func(): _on_buy_recipe(i, recipe["buy_cost"]))
				
			action_buttons_data.append({
				"button": action_btn,
				"cost": recipe["buy_cost"],
				"type": "recipe",
				"index": i
			})
				
			row.add_child(action_btn)
			recipe_list.add_child(row)
			
	elif active_tab == 1:
		# Build new chef rows
		for i in range(Global.CHEFS.size()):
			var chef = Global.CHEFS[i]
			var hired_count = Global.hired_chefs[i]
			var cost = chef["base_cost"] * pow(1.15, hired_count)
			
			var row = HBoxContainer.new()
			row.add_theme_constant_override("separation", 15)
			
			# Info VBox
			var info_vbox = VBoxContainer.new()
			info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var name_lbl = Label.new()
			name_lbl.text = chef["name"] + " (Hired: " + str(hired_count) + ")"
			name_lbl.add_theme_font_size_override("font_size", 16)
			name_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
			name_lbl.add_theme_constant_override("outline_size", 4)
			info_vbox.add_child(name_lbl)
			
			var desc_lbl = Label.new()
			desc_lbl.text = "Cook Speed: +" + Global.format_number(chef["cook_rate"]) + " pizzas/s"
			desc_lbl.add_theme_font_size_override("font_size", 12)
			desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
			info_vbox.add_child(desc_lbl)
			
			row.add_child(info_vbox)
			
			# Action Button
			var action_btn = Button.new()
			action_btn.custom_minimum_size = Vector2(160, 45)
			action_btn.add_theme_font_size_override("font_size", 13)
			
			action_btn.add_theme_stylebox_override("normal", style_normal)
			action_btn.add_theme_stylebox_override("hover", style_hover)
			action_btn.add_theme_stylebox_override("pressed", style_pressed)
			
			action_btn.text = "Hire: $" + Global.format_number(cost)
			action_btn.disabled = (Global.money < cost)
			action_btn.pressed.connect(func(): _on_hire_chef(i, cost))
			
			action_buttons_data.append({
				"button": action_btn,
				"cost": cost,
				"type": "chef",
				"index": i
			})
			
			row.add_child(action_btn)
			recipe_list.add_child(row)
			
	elif active_tab == 2:
		# Build new cashier rows
		for i in range(Global.CASHIERS.size()):
			var cashier = Global.CASHIERS[i]
			var hired_count = Global.hired_cashiers[i]
			var cost = cashier["base_cost"] * pow(1.15, hired_count)
			
			var row = HBoxContainer.new()
			row.add_theme_constant_override("separation", 15)
			
			# Info VBox
			var info_vbox = VBoxContainer.new()
			info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var name_lbl = Label.new()
			name_lbl.text = cashier["name"] + " (Hired: " + str(hired_count) + ")"
			name_lbl.add_theme_font_size_override("font_size", 16)
			name_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
			name_lbl.add_theme_constant_override("outline_size", 4)
			info_vbox.add_child(name_lbl)
			
			var desc_lbl = Label.new()
			desc_lbl.text = "Sell Speed: +" + Global.format_number(cashier["sell_rate"]) + "/s"
			desc_lbl.add_theme_font_size_override("font_size", 12)
			desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
			info_vbox.add_child(desc_lbl)
			
			row.add_child(info_vbox)
			
			# Action Button
			var action_btn = Button.new()
			action_btn.custom_minimum_size = Vector2(160, 45)
			action_btn.add_theme_font_size_override("font_size", 13)
			
			action_btn.add_theme_stylebox_override("normal", style_normal)
			action_btn.add_theme_stylebox_override("hover", style_hover)
			action_btn.add_theme_stylebox_override("pressed", style_pressed)
			
			action_btn.text = "Hire: $" + Global.format_number(cost)
			action_btn.disabled = (Global.money < cost)
			action_btn.pressed.connect(func(): _on_hire_cashier(i, cost))
			
			action_buttons_data.append({
				"button": action_btn,
				"cost": cost,
				"type": "cashier",
				"index": i
			})
			
			row.add_child(action_btn)
			recipe_list.add_child(row)

func _on_activate_recipe(index: int):
	Global.active_recipe_index = index

func _on_buy_recipe(index: int, cost: float):
	if Global.money >= cost:
		Global.money -= cost
		Global.unlocked_recipes.append(index)
		Global.active_recipe_index = index

func _on_hire_chef(index: int, cost: float):
	if Global.money >= cost:
		Global.money -= cost
		Global.hired_chefs[index] += 1
		Global.chefs_updated.emit()

func _on_hire_cashier(index: int, cost: float):
	if Global.money >= cost:
		Global.money -= cost
		Global.hired_cashiers[index] += 1
		Global.cashiers_updated.emit()
