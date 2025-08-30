extends Node3D
class_name Tower

signal damaged
signal died
@export var health: Health

@onready var _sfx_attacked = $SfxAttacked
@onready var light = $OmniLight

func _ready() -> void:
	health.damaged.connect(damaged.emit)
	health.died.connect(died.emit)
	health.died.connect(_on_destroyed)

func take_damage(dmg: int):
	health.apply_damage(dmg)
	_sfx_attacked.play()
	print(self.name, " damaged for: ", dmg, " . Remaining: ", health)

func _on_destroyed():
	print("Tower destroyed. Lights out.")
	light.queue_free()
	
