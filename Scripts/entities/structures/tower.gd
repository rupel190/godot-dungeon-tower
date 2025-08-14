extends Node3D
class_name Tower

signal damaged
signal died
@export var health: Health

func _ready() -> void:
	health.damaged.connect(damaged.emit)
	health.damaged.connect(died.emit)
