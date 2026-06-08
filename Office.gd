extends Control

@onready var to_kitchen_button = $ToKitchenButton
@onready var recipe_list = $LaptopScreen/MarginContainer/VBoxContainer/ScrollContainer/RecipeList
@onready var money_label = $LaptopScreen/MarginContainer/VBoxContainer/Header/MoneyLabel
@onready var recipes_tab_button = $LaptopScreen/MarginContainer/VBoxContainer/TabBar/RecipesTabButton
@onready var chefs_tab_button = $LaptopScreen/MarginContainer/VBoxContainer/TabBar/ChefsTabButton
@onready var cashiers_tab_button = $LaptopScreen/MarginContainer/VBoxContainer/TabBar/CashiersTabButton
@onready var prestige_tab_button = $LaptopScreen/MarginContainer/VBoxContainer/TabBar/PrestigeTabButton

var style_normal: StyleBoxFlat
var style_hover: StyleBoxFlat
var style_pressed: StyleBoxFlat
var style_tab_active: StyleBoxFlat
var style_tab_inactive: StyleBoxFlat
var style_gold_normal: StyleBoxFlat
var style_gold_hover: StyleBoxFlat
var style_gold_pressed: StyleBoxFlat

var active_tab: int = 0 # 0 = Recipes, 1 = Chefs, 2 = Cashiers, 3 = Prestige
var action_buttons_data: Array = [] # Dictionary list: { "button": Button, "cost": float, "type": String, "index": int }

func _ready():
	to_kitchen_button.pressed.connect(_on_to_kitchen_pressed)
	recipes_tab_button.pressed.connect(func(): _on_tab_changed(0))
	chefs_tab_button.pressed.connect(func(): _on_tab_changed(1))
	cashiers_tab_button.pressed.connect(func(): _on_tab_changed(2))
	prestige_tab_button.pressed.connect(func(): _on_tab_changed(3))
	
	# Connect global updates
	Global.money_changed.connect(_on_money_changed)
	Global.recipes_updated.connect(_update_recipe_list)
	Global.chefs_updated.connect(_update_recipe_list)
	Global.cashiers_updated.connect(_update_recipe_list)
	Global.prestige_updated.connect(_update_recipe_list)
	
	# Build styles
	style_normal = _create_btn_style(Color(0.1, 0.2, 0.4, 0.9), Color(0.05, 0.1, 0.2, 0.9), 8, 2)
	style_hover = _create_btn_style(Color(0.15, 0.3, 0.5, 0.95), Color(0.4, 0.6, 0.9, 0.9), 8, 2)
	style_pressed = _create_btn_style(Color(0.05, 0.15, 0.3, 0.9), Color(0.02, 0.08, 0.15, 0.9), 2, 6)
	
	style_tab_active = _create_btn_style(Color(0.15, 0.3, 0.5, 0.95), Color(0.4, 0.6, 0.9, 0.9), 8, 2)
	style_tab_inactive = _create_btn_style(Color(0.08, 0.15, 0.25, 0.9), Color(0.04, 0.08, 0.15, 0.9), 4, 2)
	
	style_gold_normal = _create_btn_style(Color(0.85, 0.65, 0.13, 0.9), Color(0.6, 0.4, 0.05, 0.9), 8, 2)
	style_gold_hover = _create_btn_style(Color(1.0, 0.8, 0.2, 0.95), Color(0.8, 0.6, 0.1, 0.9), 8, 2)
	style_gold_pressed = _create_btn_style(Color(0.65, 0.45, 0.05, 0.9), Color(0.4, 0.2, 0.02, 0.9), 2, 6)
	
	# Restore active tab index
	active_tab = Global.active_office_tab
	
	# Initial updates
	_update_tab_buttons_appearance()
	_on_money_changed(Global.money)
	_update_recipe_list()

func _create_btn_style(bg_color: Color, border_color: Color, bottom_thick: int, top_thick: int) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_width_left = 2
	style.border_width_top = top_thick
	style.border_width_right = 2
	style.border_width_bottom = bottom_thick
	style.border_color = border_color
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
			elif data["type"] == "prestige_reset":
				var to_gain = Global.get_prestige_points_to_gain()
				if to_gain > 0:
					btn.text = "Reset for +" + str(to_gain) + " Golden Pizzas"
					btn.disabled = false
				else:
					btn.text = "Prestige (Need $100K)"
					btn.disabled = true
			else:
				btn.disabled = (amount < data["cost"])

func _on_tab_changed(tab_index: int):
	active_tab = tab_index
	Global.active_office_tab = tab_index
	_update_tab_buttons_appearance()
	_update_recipe_list()

func _update_tab_buttons_appearance():
	# Reset styles for all buttons first
	recipes_tab_button.add_theme_stylebox_override("normal", style_tab_inactive)
	recipes_tab_button.add_theme_stylebox_override("hover", style_hover)
	recipes_tab_button.add_theme_stylebox_override("pressed", style_pressed)
	
	chefs_tab_button.add_theme_stylebox_override("normal", style_tab_inactive)
	chefs_tab_button.add_theme_stylebox_override("hover", style_hover)
	chefs_tab_button.add_theme_stylebox_override("pressed", style_pressed)
	
	cashiers_tab_button.add_theme_stylebox_override("normal", style_tab_inactive)
	cashiers_tab_button.add_theme_stylebox_override("hover", style_hover)
	cashiers_tab_button.add_theme_stylebox_override("pressed", style_pressed)
	
	prestige_tab_button.add_theme_stylebox_override("normal", style_tab_inactive)
	prestige_tab_button.add_theme_stylebox_override("hover", style_hover)
	prestige_tab_button.add_theme_stylebox_override("pressed", style_pressed)
	
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
	elif active_tab == 3:
		prestige_tab_button.add_theme_stylebox_override("normal", style_tab_active)
		prestige_tab_button.add_theme_stylebox_override("hover", style_tab_active)
		prestige_tab_button.add_theme_stylebox_override("pressed", style_tab_active)

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
			name_lbl.add_theme_font_size_override("font_size", 24)
			name_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
			name_lbl.add_theme_constant_override("outline_size", 4)
			info_vbox.add_child(name_lbl)
			
			var desc_lbl = Label.new()
			desc_lbl.text = "Pizza Value: $" + Global.format_number(recipe["pizza_value"])
			desc_lbl.add_theme_font_size_override("font_size", 18)
			desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
			info_vbox.add_child(desc_lbl)
			
			row.add_child(info_vbox)
			
			# Action Button
			var action_btn = Button.new()
			action_btn.custom_minimum_size = Vector2(250, 60)
			action_btn.add_theme_font_size_override("font_size", 20)
			
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
			name_lbl.add_theme_font_size_override("font_size", 24)
			name_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
			name_lbl.add_theme_constant_override("outline_size", 4)
			info_vbox.add_child(name_lbl)
			
			var desc_lbl = Label.new()
			desc_lbl.text = "Cook Speed: +" + Global.format_number(chef["cook_rate"]) + " pizzas/s"
			desc_lbl.add_theme_font_size_override("font_size", 18)
			desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
			info_vbox.add_child(desc_lbl)
			
			row.add_child(info_vbox)
			
			# Action Button
			var action_btn = Button.new()
			action_btn.custom_minimum_size = Vector2(250, 60)
			action_btn.add_theme_font_size_override("font_size", 20)
			
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
			name_lbl.add_theme_font_size_override("font_size", 24)
			name_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
			name_lbl.add_theme_constant_override("outline_size", 4)
			info_vbox.add_child(name_lbl)
			
			var desc_lbl = Label.new()
			desc_lbl.text = "Sell Speed: +" + Global.format_number(cashier["sell_rate"]) + "/s"
			desc_lbl.add_theme_font_size_override("font_size", 18)
			desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
			info_vbox.add_child(desc_lbl)
			
			row.add_child(info_vbox)
			
			# Action Button
			var action_btn = Button.new()
			action_btn.custom_minimum_size = Vector2(250, 60)
			action_btn.add_theme_font_size_override("font_size", 20)
			
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
			
	elif active_tab == 3:
		# Build Prestige Tab UI
		
		# 1. Info Header Row (Current Golden Pizzas and Passive Bonus)
		var info_row = HBoxContainer.new()
		info_row.add_theme_constant_override("separation", 15)
		
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var gold_lbl = Label.new()
		gold_lbl.text = "Golden Pizzas Owned: " + str(Global.prestige_points)
		gold_lbl.add_theme_font_size_override("font_size", 24)
		gold_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1)) # Gold text
		gold_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		gold_lbl.add_theme_constant_override("outline_size", 4)
		info_vbox.add_child(gold_lbl)
		
		var pass_lbl = Label.new()
		var passive_bonus = Global.prestige_points * 5
		pass_lbl.text = "Current Passive Bonus: +" + str(passive_bonus) + "% Pizza Value"
		pass_lbl.add_theme_font_size_override("font_size", 18)
		pass_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1))
		info_vbox.add_child(pass_lbl)
		
		info_row.add_child(info_vbox)
		
		# Prestige/Reset Action Button
		var reset_btn = Button.new()
		reset_btn.custom_minimum_size = Vector2(250, 60)
		reset_btn.add_theme_font_size_override("font_size", 18)
		reset_btn.add_theme_stylebox_override("normal", style_gold_normal)
		reset_btn.add_theme_stylebox_override("hover", style_gold_hover)
		reset_btn.add_theme_stylebox_override("pressed", style_gold_pressed)
		
		var to_gain = Global.get_prestige_points_to_gain()
		if to_gain > 0:
			reset_btn.text = "Reset for +" + str(to_gain) + " Golden Pizzas"
			reset_btn.disabled = false
		else:
			reset_btn.text = "Prestige (Need $100K)"
			reset_btn.disabled = true
			
		reset_btn.pressed.connect(_on_prestige_pressed)
		info_row.add_child(reset_btn)
		
		action_buttons_data.append({
			"button": reset_btn,
			"cost": 100000.0,
			"type": "prestige_reset",
			"index": 0
		})
		
		recipe_list.add_child(info_row)
		
		# Visual separator line
		var separator = ColorRect.new()
		separator.custom_minimum_size = Vector2(0, 2)
		separator.color = Color(1.0, 0.85, 0.2, 0.3)
		recipe_list.add_child(separator)
		
		# 2. Golden Upgrades List
		var upgrades_data = [
			{
				"id": "golden_crust",
				"name": "Golden Crust",
				"desc_func": func(lvl): return "Pizza Sell Value: +" + str(lvl * 10) + "%",
				"next_func": func(lvl): return "Next level: +" + str((lvl + 1) * 10) + "%",
				"cost_func": func(lvl): return lvl + 1,
				"max_level": 9999
			},
			{
				"id": "kitchen_rush",
				"name": "Kitchen Rush",
				"desc_func": func(lvl): return "Chef Cooking Speed: +" + str(lvl * 10) + "%",
				"next_func": func(lvl): return "Next level: +" + str((lvl + 1) * 10) + "%",
				"cost_func": func(lvl): return lvl + 1,
				"max_level": 9999
			},
			{
				"id": "sales_pitch",
				"name": "Sales Pitch",
				"desc_func": func(lvl): return "Cashier Selling Speed: +" + str(lvl * 10) + "%",
				"next_func": func(lvl): return "Next level: +" + str((lvl + 1) * 10) + "%",
				"cost_func": func(lvl): return lvl + 1,
				"max_level": 9999
			},
			{
				"id": "master_baker",
				"name": "Master Baker",
				"desc_func": func(lvl): return "Baking Clicks Needed: " + str(max(1, 5 - lvl)),
				"next_func": func(lvl): return "Next level: " + str(max(1, 4 - lvl)) + " clicks",
				"cost_func": func(lvl):
					var costs = [2, 5, 10, 25]
					return costs[min(lvl, costs.size() - 1)],
				"max_level": 4
			}
		]
		
		for upg in upgrades_data:
			var lvl = Global.prestige_upgrades.get(upg["id"], 0)
			var cost = upg["cost_func"].call(lvl)
			var is_max = lvl >= upg["max_level"]
			
			var row = HBoxContainer.new()
			row.add_theme_constant_override("separation", 15)
			
			var upg_vbox = VBoxContainer.new()
			upg_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var name_lbl = Label.new()
			name_lbl.text = upg["name"] + " (Lvl " + str(lvl) + ")"
			name_lbl.add_theme_font_size_override("font_size", 22)
			name_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
			name_lbl.add_theme_constant_override("outline_size", 4)
			upg_vbox.add_child(name_lbl)
			
			var desc_lbl = Label.new()
			if is_max:
				desc_lbl.text = upg["desc_func"].call(lvl) + " (MAX)"
			else:
				desc_lbl.text = upg["desc_func"].call(lvl) + " | " + upg["next_func"].call(lvl)
			desc_lbl.add_theme_font_size_override("font_size", 16)
			desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
			upg_vbox.add_child(desc_lbl)
			
			row.add_child(upg_vbox)
			
			var buy_btn = Button.new()
			buy_btn.custom_minimum_size = Vector2(250, 60)
			buy_btn.add_theme_font_size_override("font_size", 18)
			
			buy_btn.add_theme_stylebox_override("normal", style_normal)
			buy_btn.add_theme_stylebox_override("hover", style_hover)
			buy_btn.add_theme_stylebox_override("pressed", style_pressed)
			
			if is_max:
				buy_btn.text = "MAX LEVEL"
				buy_btn.disabled = true
			else:
				buy_btn.text = "Buy: " + str(cost) + " GP"
				buy_btn.disabled = (Global.prestige_points < cost)
				buy_btn.pressed.connect(func(): _on_buy_prestige_upgrade(upg["id"], cost))
				
			row.add_child(buy_btn)
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

func _on_prestige_pressed():
	var confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.title = "Prestige Confirmation"
	confirm_dialog.dialog_text = "Are you sure you want to prestige?\n\nThis will reset your cash, pizzas, chef/cashier staff, and recipes in exchange for Golden Pizzas.\n\nAll your prestige upgrades will be kept!"
	confirm_dialog.confirmed.connect(func():
		Global.play_prestige_transition()
	)
	add_child(confirm_dialog)
	confirm_dialog.popup_centered()

func _on_buy_prestige_upgrade(upgrade_id: String, cost: int):
	if Global.prestige_points >= cost:
		Global.prestige_points -= cost
		Global.prestige_upgrades[upgrade_id] += 1
		Global.prestige_updated.emit()
		Global.save_game()
