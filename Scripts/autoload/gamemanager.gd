extends Node
const GAMEOVER_SCREEN:PackedScene = preload("res://Scenes/Ui/GameOver.tscn")
signal gameover(score: String)
signal restart()

enum SpawnType {
		PLAYER,
		ENEMY,
		TOWER
}

func _ready() -> void:
	gameover.connect(_gameover)
	restart.connect(_restart)

func _gameover(score: String):
	print("THE GAME HATH COME TO AN END!")
	UserInterface.visible = false
	var screen:Node = GAMEOVER_SCREEN.instantiate()
	get_tree().root.add_child(screen)

func _restart():
	print("restart")
	get_tree().change_scene_to_file("res://Scenes/Levels/Maze.tscn")
