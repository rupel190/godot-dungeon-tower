extends Node

const GAMEOVER_SCREEN: PackedScene = preload("res://Scenes/Ui/GameOver.tscn")
const MAZE_SCENE: PackedScene = preload("res://Scenes/Levels/Maze.tscn")

signal restart
signal gameover

var active_towers = 0
var active_enemies = 0

func _ready() -> void:
	restart.connect(_restart)
	gameover.connect(_gameover)
	
	SignalBus.tower_spawned.connect(_on_tower_spawned)
	SignalBus.enemy_spawned.connect(_on_enemy_spawned)
	SignalBus.tower_destroyed.connect(_on_tower_destroyed)
	SignalBus.enemy_destroyed.connect(_on_enemy_destroyed)

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
	
	
func _on_tower_spawned():
	print("Tower spawned!")
	active_towers += 1
	
func _on_tower_destroyed(tower: Tower):
	active_towers -= 1
	if tower.is_main:
		_gameover("ZERO ZERO ZERO")
	print("Remaining towers: ", active_towers)
	UserInterface.notify("Tower has been destroyed!")
	
	
func _on_enemy_spawned():
	print("Enemy spawned!")
	active_enemies += 1
	
func _on_enemy_destroyed():
	active_enemies -= 1
	print("Remaining enemies: ", active_enemies)
	UserInterface.notify("An enemy has been destroyed!")
	
