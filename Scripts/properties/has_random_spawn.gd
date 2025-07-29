extends Node

var spawn = Vector3.ZERO
@export var spawn_devhint = "PlayerSpawnDev"
var gridmap: Map

func _calc_random_spawn():
	print("Calculating random spawn for: ", get_parent().name)
	if !gridmap:
		print("Random spawn requires gridmap to function!", get_parent().name)
	var devhint = gridmap.find_gridmap_devhints(spawn_devhint)
	var spawn_nodes = gridmap.find_cells(devhint)
	var random_spawn = spawn_nodes.pick_random()
	
	for s in spawn_nodes:
		gridmap.remove_gridmap_devhint(s)
		
	return gridmap.make_global(random_spawn)
	

	
