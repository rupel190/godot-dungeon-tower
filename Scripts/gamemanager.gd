extends Node

signal gameover(score: String)

enum SpawnType {
	PLAYER,
	ENEMY,
	TOWER
}

func _ready() -> void:
	gameover.connect(_gameover)

func _gameover(score: String):
	print("THE GAME HATH COME TO AN END!")
