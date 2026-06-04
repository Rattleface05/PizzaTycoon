extends Control

@onready var main_panel = $MainPanel
@onready var settings_panel = $SettingsPanel

@onready var start_button = $MainPanel/PanelContainer/VBoxContainer/StartButton
@onready var settings_button = $MainPanel/PanelContainer/VBoxContainer/SettingsButton
@onready var quit_button = $MainPanel/PanelContainer/VBoxContainer/QuitButton

@onready var mute_checkbox = $SettingsPanel/PanelContainer/VBoxContainer/MuteContainer/CheckBoxBorder/MuteCheckBox
@onready var resolution_option = $SettingsPanel/PanelContainer/VBoxContainer/ResolutionContainer/ResolutionOptionButton
@onready var back_button = $SettingsPanel/PanelContainer/BackButton

@onready var background_texture = $BackgroundTexture

var bg_frames: Array[Texture2D] = []
var bg_current_frame: int = 0
var bg_timer: float = 0.0
const BG_FPS: float = 12.5

const RESOLUTIONS = [
	Vector2i(800, 600),
	Vector2i(1152, 648),
	Vector2i(1280, 720),
	Vector2i(1920, 1080)
]

func _ready():
	# Configure initial visibility
	main_panel.visible = true
	settings_panel.visible = false
	
	# Load GIF background frames
	for i in range(18):
		var frame_path = "res://space_pizza_frames/frame_" + str(i) + ".png"
		var tex = load(frame_path)
		if tex:
			bg_frames.append(tex)
	if bg_frames.size() > 0:
		background_texture.texture = bg_frames[0]
	
	# Connect buttons
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Audio settings setup
	var master_bus_idx = AudioServer.get_bus_index("Master")
	var is_muted = AudioServer.is_bus_mute(master_bus_idx)
	mute_checkbox.button_pressed = is_muted
	mute_checkbox.toggled.connect(_on_mute_toggled)
	
	# Video settings setup
	resolution_option.clear()
	for res in RESOLUTIONS:
		resolution_option.add_item(str(res.x) + "x" + str(res.y))
	
	# Find current window size and select it in option button if matches
	var current_size = DisplayServer.window_get_size()
	var found_idx = RESOLUTIONS.find(current_size)
	if found_idx != -1:
		resolution_option.selected = found_idx
	else:
		# Default to 1152x648
		resolution_option.selected = 1
		
	resolution_option.item_selected.connect(_on_resolution_selected)

func _process(delta):
	# Animate GIF background
	if bg_frames.size() > 1:
		bg_timer += delta
		var time_per_frame = 1.0 / BG_FPS
		if bg_timer >= time_per_frame:
			bg_timer -= time_per_frame
			bg_current_frame = (bg_current_frame + 1) % bg_frames.size()
			background_texture.texture = bg_frames[bg_current_frame]

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Kitchen.tscn")

func _on_settings_pressed():
	main_panel.visible = false
	settings_panel.visible = true

func _on_quit_pressed():
	get_tree().quit()

func _on_back_pressed():
	settings_panel.visible = false
	main_panel.visible = true

func _on_mute_toggled(button_pressed: bool):
	var master_bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus_idx, button_pressed)

func _on_resolution_selected(index: int):
	if index >= 0 and index < RESOLUTIONS.size():
		var target_size = RESOLUTIONS[index]
		DisplayServer.window_set_size(target_size)
		# Re-center window
		var screen = DisplayServer.window_get_current_screen()
		var screen_size = DisplayServer.screen_get_size(screen)
		var window_size = DisplayServer.window_get_size()
		var center_pos = screen_size / 2 - window_size / 2
		DisplayServer.window_set_position(center_pos)
