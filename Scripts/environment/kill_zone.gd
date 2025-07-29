extends Area3D
class_name Killzone

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(on_body_entered)


func on_body_entered(body:Node3D):
	if body.is_in_group("Player"):
		Gamemanager.gameover.emit("Player entered Killzone")
