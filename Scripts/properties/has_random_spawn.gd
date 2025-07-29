extends Node

var spawn = Vector3.ZERO

@export var spawn_devhint: Gamemanager.SpawnType
@export var map: Map

func _ready() -> void:
		_calc_random_spawn()

func _calc_random_spawn():
	print("Calculating random spawn for: ", get_parent().name)
	if !map:
			print("Error: Random spawn requires gridmap to function! ", get_parent().name)
	if !spawn_devhint:
			print("Error: Spawn devhint required: ", Gamemanager.SpawnType.values())

	var devhint = map.find_gridmap_devhint(spawn_devhint)
	var spawn_nodes = map.find_cells(devhint)
	var random_spawn = spawn_nodes.pick_random()

	spawn = map.make_global(random_spawn)
