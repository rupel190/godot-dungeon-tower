extends Node3D
class_name Tower

@export var health: Health
@export var is_main = false

@onready var _sfx_attacked = $SfxAttacked
@onready var _light = $OmniLight


func _ready() -> void:
	health.died.connect(_on_destroyed)

func take_damage(dmg: int):
	health.apply_damage(dmg)
	_sfx_attacked.play()
	print(self.name, " damaged for: ", dmg, " . Remaining: ", health)

func _on_destroyed():
	SignalBus.tower_destroyed.emit(self)
	print("Tower destroyed. Lights out.")
	_light.queue_free()
	
