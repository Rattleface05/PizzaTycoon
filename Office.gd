extends Control

@onready var to_kitchen_button = $ToKitchenButton

func _ready():
	to_kitchen_button.pressed.connect(_on_to_kitchen_pressed)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_D:
			_on_to_kitchen_pressed()

func _on_to_kitchen_pressed():
	Global.change_scene("res://Kitchen.tscn")
