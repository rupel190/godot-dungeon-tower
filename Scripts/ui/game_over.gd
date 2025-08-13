extends MarginContainer


func _on_restart_button_up() -> void:
	Gamemanager.restart.emit()
	queue_free()
