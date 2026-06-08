extends CanvasLayer

var overlay: ColorRect
var panel_container: PanelContainer
var vbox: VBoxContainer
var settings_vbox: VBoxContainer
var title_lbl: Label
var resume_btn: Button
var settings_btn: Button
var quit_btn: Button
var info_lbl: Label

var settings_title: Label
var mute_checkbox: CheckBox
var back_btn: Button

func _ready():
	# Overlay with Blur Shader
	overlay = ColorRect.new()
	overlay.color = Color(1, 1, 1, 1) # Color doesn't matter for shader, but let's keep it white
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var shader = preload("res://blur.gdshader")
	var mat = ShaderMaterial.new()
	mat.shader = shader
	overlay.material = mat
	add_child(overlay)
	
	# Main container
	panel_container = PanelContainer.new()
	panel_container.anchors_preset = Control.PRESET_FULL_RECT
	panel_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(panel_container)
	
	var empty_style = StyleBoxEmpty.new()
	panel_container.add_theme_stylebox_override("panel", empty_style)
	
	# Main VBox
	vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 25)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	# Force it to center itself in the full rect panel
	vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel_container.add_child(vbox)
	
	# Title
	title_lbl = Label.new()
	title_lbl.text = "Game Paused"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 64)
	title_lbl.add_theme_color_override("font_color", Color(0.95, 0.35, 0.35, 1))
	title_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	title_lbl.add_theme_constant_override("outline_size", 12)
	vbox.add_child(title_lbl)
	
	# Style Setup
	var style_btn_normal = StyleBoxFlat.new()
	style_btn_normal.bg_color = Color(0.35, 0.1, 0.05, 0.9)
	style_btn_normal.border_width_left = 2
	style_btn_normal.border_width_top = 2
	style_btn_normal.border_width_right = 2
	style_btn_normal.border_width_bottom = 8
	style_btn_normal.border_color = Color(0.2, 0.05, 0.02, 0.9)
	style_btn_normal.corner_radius_top_left = 8
	style_btn_normal.corner_radius_top_right = 8
	style_btn_normal.corner_radius_bottom_right = 8
	style_btn_normal.corner_radius_bottom_left = 8
	
	var style_btn_hover = StyleBoxFlat.new()
	style_btn_hover.bg_color = Color(0.45, 0.15, 0.08, 0.95)
	style_btn_hover.border_width_left = 2
	style_btn_hover.border_width_top = 2
	style_btn_hover.border_width_right = 2
	style_btn_hover.border_width_bottom = 8
	style_btn_hover.border_color = Color(0.3, 0.08, 0.04, 0.95)
	style_btn_hover.corner_radius_top_left = 8
	style_btn_hover.corner_radius_top_right = 8
	style_btn_hover.corner_radius_bottom_right = 8
	style_btn_hover.corner_radius_bottom_left = 8
	
	var style_btn_pressed = StyleBoxFlat.new()
	style_btn_pressed.bg_color = Color(0.25, 0.08, 0.04, 0.9)
	style_btn_pressed.border_width_left = 2
	style_btn_pressed.border_width_top = 6
	style_btn_pressed.border_width_right = 2
	style_btn_pressed.border_width_bottom = 2
	style_btn_pressed.border_color = Color(0.15, 0.03, 0.01, 0.9)
	style_btn_pressed.corner_radius_top_left = 8
	style_btn_pressed.corner_radius_top_right = 8
	style_btn_pressed.corner_radius_bottom_right = 8
	style_btn_pressed.corner_radius_bottom_left = 8

	var create_btn = func(txt: String) -> Button:
		var btn = Button.new()
		btn.text = txt
		btn.custom_minimum_size = Vector2(400, 75)
		btn.add_theme_font_size_override("font_size", 36)
		btn.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		btn.add_theme_constant_override("outline_size", 6)
		btn.add_theme_stylebox_override("normal", style_btn_normal)
		btn.add_theme_stylebox_override("hover", style_btn_hover)
		btn.add_theme_stylebox_override("pressed", style_btn_pressed)
		return btn
	
	resume_btn = create_btn.call("Resume")
	resume_btn.pressed.connect(_on_resume_pressed)
	vbox.add_child(resume_btn)
	
	settings_btn = create_btn.call("Settings")
	settings_btn.pressed.connect(_on_settings_pressed)
	vbox.add_child(settings_btn)
	
	quit_btn = create_btn.call("Save and Quit to Menu")
	quit_btn.pressed.connect(_on_quit_pressed)
	vbox.add_child(quit_btn)
	
	info_lbl = Label.new()
	info_lbl.text = ""
	info_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_lbl.add_theme_font_size_override("font_size", 24)
	info_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4, 1))
	info_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	info_lbl.add_theme_constant_override("outline_size", 4)
	vbox.add_child(info_lbl)
	
	# --- Settings VBox ---
	settings_vbox = VBoxContainer.new()
	settings_vbox.add_theme_constant_override("separation", 25)
	settings_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	settings_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	settings_vbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	settings_vbox.visible = false
	panel_container.add_child(settings_vbox)
	
	settings_title = Label.new()
	settings_title.text = "Settings"
	settings_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_title.add_theme_font_size_override("font_size", 64)
	settings_title.add_theme_color_override("font_color", Color(0.95, 0.35, 0.35, 1))
	settings_title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	settings_title.add_theme_constant_override("outline_size", 12)
	settings_vbox.add_child(settings_title)
	
	var mute_hb = HBoxContainer.new()
	mute_hb.alignment = BoxContainer.ALIGNMENT_CENTER
	mute_hb.add_theme_constant_override("separation", 20)
	
	var mute_lbl = Label.new()
	mute_lbl.text = "Mute Audio:"
	mute_lbl.add_theme_font_size_override("font_size", 36)
	mute_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	mute_lbl.add_theme_constant_override("outline_size", 6)
	mute_hb.add_child(mute_lbl)
	
	mute_checkbox = CheckBox.new()
	var master_bus_idx = AudioServer.get_bus_index("Master")
	mute_checkbox.button_pressed = AudioServer.is_bus_mute(master_bus_idx)
	mute_checkbox.toggled.connect(_on_mute_toggled)
	
	var cb_panel = PanelContainer.new()
	var cb_style = StyleBoxFlat.new()
	cb_style.bg_color = Color(0,0,0, 0.5)
	cb_style.border_width_left = 2; cb_style.border_width_top = 2
	cb_style.border_width_right = 2; cb_style.border_width_bottom = 2
	cb_style.border_color = Color(0.95, 0.35, 0.35, 0.5)
	cb_panel.add_theme_stylebox_override("panel", cb_style)
	cb_panel.add_child(mute_checkbox)
	mute_hb.add_child(cb_panel)
	
	settings_vbox.add_child(mute_hb)
	
	back_btn = create_btn.call("Back")
	back_btn.pressed.connect(_on_back_pressed)
	settings_vbox.add_child(back_btn)
	
	overlay.visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		var current_scene = get_tree().current_scene
		if current_scene and current_scene.name == "MainMenu":
			return
		
		# If we are in settings, ESC goes back to pause menu
		if overlay.visible and settings_vbox.visible:
			_on_back_pressed()
			return
			
		_toggle_pause()

func _toggle_pause():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	overlay.visible = new_pause_state
	if new_pause_state:
		info_lbl.text = ""
		vbox.visible = true
		settings_vbox.visible = false
		
		var master_bus_idx = AudioServer.get_bus_index("Master")
		mute_checkbox.set_pressed_no_signal(AudioServer.is_bus_mute(master_bus_idx))

func _on_resume_pressed():
	_toggle_pause()

func _on_settings_pressed():
	vbox.visible = false
	settings_vbox.visible = true

func _on_back_pressed():
	settings_vbox.visible = false
	vbox.visible = true

func _on_mute_toggled(toggled_on: bool):
	var master_bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus_idx, toggled_on)

func _on_quit_pressed():
	Global.save_game()
	get_tree().paused = false
	overlay.visible = false
	get_tree().change_scene_to_file("res://MainMenu.tscn")
