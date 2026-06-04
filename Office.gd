extends Control

@onready var to_kitchen_button = $ToKitchenButton
@onready var recipe_list = $LaptopScreen/VBoxContainer/ScrollContainer/RecipeList
@onready var money_label = $LaptopScreen/VBoxContainer/Header/MoneyLabel

var style_normal: StyleBoxFlat
var style_hover: StyleBoxFlat
var style_pressed: StyleBoxFlat

func _ready():
	to_kitchen_button.pressed.connect(_on_to_kitchen_pressed)
	
	# Connect global updates
	Global.money_changed.connect(_on_money_changed)
	Global.recipes_updated.connect(_update_recipe_list)
	
	# Build styles
	style_normal = _create_btn_style(Color(0.18, 0.18, 0.24, 0.9))
	style_hover = _create_btn_style(Color(0.28, 0.28, 0.36, 0.95))
	style_pressed = _create_btn_style(Color(0.12, 0.12, 0.16, 0.9))
	
	# Initial updates
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
	money_label.text = "Cash: $" + str(snapped(amount, 0.01)) + " "
	# Rebuild to update buy buttons enable/disable state
	_update_recipe_list()

func _update_recipe_list():
	if not recipe_list:
		return
		
	# Clear old rows
	for child in recipe_list.get_children():
		child.queue_free()
		
	# Build new rows
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
		name_lbl.add_theme_font_size_override("font_size", 18)
		name_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		name_lbl.add_theme_constant_override("outline_size", 4)
		info_vbox.add_child(name_lbl)
		
		var desc_lbl = Label.new()
		desc_lbl.text = "Pizza Value: $" + str(recipe["pizza_value"])
		desc_lbl.add_theme_font_size_override("font_size", 14)
		desc_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1))
		info_vbox.add_child(desc_lbl)
		
		row.add_child(info_vbox)
		
		# Action Button
		var action_btn = Button.new()
		action_btn.custom_minimum_size = Vector2(180, 50)
		action_btn.add_theme_font_size_override("font_size", 14)
		
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
			action_btn.text = "Buy: $" + str(recipe["buy_cost"])
			action_btn.disabled = (Global.money < recipe["buy_cost"])
			action_btn.pressed.connect(func(): _on_buy_recipe(i, recipe["buy_cost"]))
			
		row.add_child(action_btn)
		recipe_list.add_child(row)

func _on_activate_recipe(index: int):
	Global.active_recipe_index = index

func _on_buy_recipe(index: int, cost: float):
	if Global.money >= cost:
		Global.money -= cost
		Global.unlocked_recipes.append(index)
		Global.active_recipe_index = index
