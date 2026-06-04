extends CanvasLayer

var overlay: ColorRect
var panel_container: PanelContainer
var vbox: VBoxContainer
var title_lbl: Label
var resume_btn: Button
var save_btn: Button
var quit_btn: Button
var info_lbl: Label

func _ready():
	# Build layout programmatically
	# Dark transparent overlay
	overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	
	# Card container
	panel_container = PanelContainer.new()
	panel_container.custom_minimum_size = Vector2(360, 280)
	panel_container.anchors_preset = Control.PRESET_CENTER
	panel_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	overlay.add_child(panel_container)
	
	# Card styling
	var style_card = StyleBoxFlat.new()
	style_card.bg_color = Color(0.08, 0.08, 0.12, 0.95)
	style_card.border_width_left = 2
	style_card.border_width_top = 2
	style_card.border_width_right = 2
	style_card.border_width_bottom = 2
	style_card.border_color = Color(1, 1, 1, 0.15)
	style_card.corner_radius_top_left = 16
	style_card.corner_radius_top_right = 16
	style_card.corner_radius_bottom_right = 16
	style_card.corner_radius_bottom_left = 16
	style_card.expand_margin_left = 15
	style_card.expand_margin_top = 15
	style_card.expand_margin_right = 15
	style_card.expand_margin_bottom = 15
	panel_container.add_theme_stylebox_override("panel", style_card)
	
	# VBox
	vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel_container.add_child(vbox)
	
	# Title
	title_lbl = Label.new()
	title_lbl.text = "Game Paused"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 32)
	title_lbl.add_theme_color_override("font_color", Color(0.95, 0.35, 0.35, 1))
	title_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	title_lbl.add_theme_constant_override("outline_size", 8)
	vbox.add_child(title_lbl)
	
	# Buttons styling
	var style_btn_normal = StyleBoxFlat.new()
	style_btn_normal.bg_color = Color(0.18, 0.18, 0.24, 0.9)
	style_btn_normal.border_width_left = 1
	style_btn_normal.border_width_top = 1
	style_btn_normal.border_width_right = 1
	style_btn_normal.border_width_bottom = 1
	style_btn_normal.border_color = Color(1, 1, 1, 0.15)
	style_btn_normal.corner_radius_top_left = 8
	style_btn_normal.corner_radius_top_right = 8
	style_btn_normal.corner_radius_bottom_right = 8
	style_btn_normal.corner_radius_bottom_left = 8
	
	var style_btn_hover = StyleBoxFlat.new()
	style_btn_hover.bg_color = Color(0.28, 0.28, 0.36, 0.95)
	style_btn_hover.border_width_left = 2
	style_btn_hover.border_width_top = 2
	style_btn_hover.border_width_right = 2
	style_btn_hover.border_width_bottom = 2
	style_btn_hover.border_color = Color(0.9, 0.3, 0.3, 0.9)
	style_btn_hover.corner_radius_top_left = 8
	style_btn_hover.corner_radius_top_right = 8
	style_btn_hover.corner_radius_bottom_right = 8
	style_btn_hover.corner_radius_bottom_left = 8
	
	var style_btn_pressed = StyleBoxFlat.new()
	style_btn_pressed.bg_color = Color(0.12, 0.12, 0.16, 0.9)
	style_btn_pressed.border_width_left = 1
	style_btn_pressed.border_width_top = 1
	style_btn_pressed.border_width_right = 1
	style_btn_pressed.border_width_bottom = 1
	style_btn_pressed.border_color = Color(1, 1, 1, 0.05)
	style_btn_pressed.corner_radius_top_left = 8
	style_btn_pressed.corner_radius_top_right = 8
	style_btn_pressed.corner_radius_bottom_right = 8
	style_btn_pressed.corner_radius_bottom_left = 8
	
	# Resume Button
	resume_btn = Button.new()
	resume_btn.text = "Resume"
	resume_btn.custom_minimum_size = Vector2(280, 45)
	resume_btn.add_theme_font_size_override("font_size", 20)
	resume_btn.add_theme_stylebox_override("normal", style_btn_normal)
	resume_btn.add_theme_stylebox_override("hover", style_btn_hover)
	resume_btn.add_theme_stylebox_override("pressed", style_btn_pressed)
	resume_btn.pressed.connect(_on_resume_pressed)
	vbox.add_child(resume_btn)
	
	# Save Button
	save_btn = Button.new()
	save_btn.text = "Save Progress"
	save_btn.custom_minimum_size = Vector2(280, 45)
	save_btn.add_theme_font_size_override("font_size", 20)
	save_btn.add_theme_stylebox_override("normal", style_btn_normal)
	save_btn.add_theme_stylebox_override("hover", style_btn_hover)
	save_btn.add_theme_stylebox_override("pressed", style_btn_pressed)
	save_btn.pressed.connect(_on_save_pressed)
	vbox.add_child(save_btn)
	
	# Quit Button
	quit_btn = Button.new()
	quit_btn.text = "Quit to Main Menu"
	quit_btn.custom_minimum_size = Vector2(280, 45)
	quit_btn.add_theme_font_size_override("font_size", 20)
	quit_btn.add_theme_stylebox_override("normal", style_btn_normal)
	quit_btn.add_theme_stylebox_override("hover", style_btn_hover)
	quit_btn.add_theme_stylebox_override("pressed", style_btn_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	vbox.add_child(quit_btn)
	
	# Info / Saved notification Label
	info_lbl = Label.new()
	info_lbl.text = ""
	info_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_lbl.add_theme_font_size_override("font_size", 14)
	info_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4, 1))
	vbox.add_child(info_lbl)
	
	# Hide overlay by default
	overlay.visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		# Prevent pausing on Main Menu scene
		var current_scene = get_tree().current_scene
		if current_scene and current_scene.name == "MainMenu":
			return
			
		_toggle_pause()

func _toggle_pause():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	overlay.visible = new_pause_state
	if new_pause_state:
		info_lbl.text = "" # Clear old save notification text

func _on_resume_pressed():
	_toggle_pause()

func _on_save_pressed():
	Global.save_game()
	info_lbl.text = "Progress Saved!"
	# Clear the label after a delay
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(func():
		if is_instance_valid(info_lbl) and info_lbl.text == "Progress Saved!":
			info_lbl.text = ""
	)

func _on_quit_pressed():
	Global.save_game() # Auto-save before quitting
	get_tree().paused = false
	overlay.visible = false
	get_tree().change_scene_to_file("res://MainMenu.tscn")
