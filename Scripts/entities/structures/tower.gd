extends Node3D
class_name Tower

signal damaged
signal died
@export var health: Health

@onready var _sfx_attacked = $SfxAttacked

func _ready() -> void:
	health.damaged.connect(damaged.emit)
	health.damaged.connect(died.emit)

func take_damage(dmg: int):
	health.apply_damage(dmg)
	_sfx_attacked.play()
	print(self.name, " damaged for: ", dmg, " . Remaining: ", health)
