extends Node2D

var textures = [
	preload("res://textures/people/chris.png"),
	preload("res://textures/people/dylan.png"),
	preload("res://textures/people/ian.png"),
	preload("res://textures/people/jane.png"),
	preload("res://textures/people/john.png"),
	preload("res://textures/people/johnny.png")
]

var orders = [
	"O pizza delicioasa, te rog!",
	"Mi-e pofta de o Margherita!",
	"Una cu extra branza!",
	"Cea mai buna pizza de aici!",
	"O felie, te rog!",
	"Sunt infometat, da-mi o pizza!"
]

@onready var sprite = $Sprite2D
@onready var order_label = $Panel/OrderLabel
@onready var panel = $Panel

func _ready():
	var play_anim = false
	if Global.current_customer_texture_index == -1:
		Global.current_customer_texture_index = randi() % textures.size()
		Global.current_customer_order_index = randi() % orders.size()
		play_anim = true
		
	sprite.texture = textures[Global.current_customer_texture_index]
	order_label.text = orders[Global.current_customer_order_index]
	
	var tex_size = sprite.texture.get_size()
	if tex_size.y > 0:
		var scale_factor = 450.0 / tex_size.y # I-am facut putin mai mari sa se vada bine
		sprite.scale = Vector2(scale_factor, scale_factor)
	
	# Punctul zero (0,0) al scenei va fi la picioarele clientului
	sprite.position.y = - (tex_size.y * sprite.scale.y) / 2
	panel.position.y = - (tex_size.y * sprite.scale.y) - 60
	
	if play_anim:
		# Animatie de intrare (Fade In si slide up)
		var target_y = position.y
		position.y += 100
		modulate.a = 0.0
		
		var tween = create_tween()
		tween.tween_property(self, "position:y", target_y, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(self, "modulate:a", 1.0, 0.5)
	else:
		modulate.a = 1.0

func leave():
	# Dupa ce primeste comanda, multumeste si pleaca
	order_label.text = "Mersi mult!"
	
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 50, 0.5)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
