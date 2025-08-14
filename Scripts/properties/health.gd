class_name Health
extends Resource

@export var hp: int = 100

signal died
signal damaged(amount: int)

func apply_damage(amount: int) -> void:
	if amount <= 0: return
	
	hp = max(hp - amount, 0)
	damaged.emit(amount)
	
	if hp <= 0:
		died.emit()
