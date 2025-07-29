extends Node3D
class_name Map

var spawn_name = {
	Gamemanager.SpawnType.PLAYER: "PlayerSpawnDev",
	Gamemanager.SpawnType.ENEMY: "EnemySpawnDev",
	Gamemanager.SpawnType.TOWER: "TowerSpawnDev",
}

@export var debug_hints:bool = false
@export var gridmap:GridMap
@export var navmap:NavigationRegion3D

func _ready() -> void:
	$Player.position = $Player/hasRandomSpawn.spawn
	$Enemy.position = $Enemy/hasRandomSpawn.spawn
	$Tower.position = $Tower/hasRandomSpawn.spawn
	
	_clear_gridmap_devhints(Gamemanager.SpawnType.PLAYER)
	_clear_gridmap_devhints(Gamemanager.SpawnType.ENEMY)
	_clear_gridmap_devhints(Gamemanager.SpawnType.TOWER)
	
	navmap.bake_navigation_mesh(true)
	
## [param hintname] hint
func find_gridmap_devhint(spawntype: Gamemanager.SpawnType) -> int:
	print(gridmap.mesh_library.get_item_list())
	return gridmap.mesh_library.find_item_by_name(spawn_name[spawntype])

func find_cells(devhint_id: int) -> Array[Vector3i]:
	return gridmap.get_used_cells_by_item(devhint_id)
	
func remove_gridmap_devhint(local_cell_pos):
	if debug_hints == false:
		gridmap.set_cell_item(local_cell_pos,-1,0)

func make_global(cell_pos) -> Vector3:
	return gridmap.to_global(gridmap.map_to_local(cell_pos))
	
func _clear_gridmap_devhints(spawntype: Gamemanager.SpawnType):
	var hint = find_gridmap_devhint(spawntype)
	for s in find_cells(hint):
		remove_gridmap_devhint(s)
