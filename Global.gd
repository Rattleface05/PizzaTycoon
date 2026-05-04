extends Node

signal money_changed(new_amount)
signal pizzas_ready_changed(new_amount)
signal level_changed(new_level)

var money: float = 0.0:
	set(value):
		money = value
		money_changed.emit(money)

var pizzas_ready: int = 0:
	set(value):
		pizzas_ready = value
		pizzas_ready_changed.emit(pizzas_ready)

var upgrade_level: int = 0:
	set(value):
		upgrade_level = value
		level_changed.emit(upgrade_level)
