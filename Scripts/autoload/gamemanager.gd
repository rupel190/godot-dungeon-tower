extends Node

const GAMEOVER_SCREEN: PackedScene = preload("res://Scenes/Ui/GameOver.tscn")
const MAZE_SCENE: PackedScene = preload("res://Scenes/Levels/Maze.tscn")
signal gameover(score: String)
signal restart()



func _ready() -> void:
	gameover.connect(_gameover)
	restart.connect(_restart)

func _gameover(score: String):
	UserInterface.visible = false
	var screen:Node = GAMEOVER_SCREEN.instantiate()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().root.add_child(screen)

func _restart():
	print("restart")
	get_tree().reload_current_scene()
	UserInterface.reset_timer()
	UserInterface.visible = true
	#get_tree().change_scene_to_packed(MAZE_SCENE)
	
