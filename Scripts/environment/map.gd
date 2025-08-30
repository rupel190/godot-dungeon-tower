extends Node3D
class_name Map

enum SpawnType {
	PLAYER,
	ENEMY,
	TOWER
}

# Mapping of GridMap names
var _spawn_name = {
	SpawnType.PLAYER: "PlayerSpawnDev",
	SpawnType.ENEMY: "EnemySpawnDev",
	SpawnType.TOWER: "TowerSpawnDev",
}


@export var debug_hints:bool = false
@export var gridmap:GridMap
@export var navmap:NavigationRegion3D

@onready var _player = $Player
@onready var _enemy = $Enemy
@onready var _tower = $Tower

func _ready() -> void:
	_player.position = _spawn(SpawnType.PLAYER)
	_enemy.position = _spawn(SpawnType.ENEMY)
	_tower.position = _spawn(SpawnType.TOWER)
	_tower.position.y = 0
	
	_clear_gridmap_devhints(SpawnType.PLAYER)
	_clear_gridmap_devhints(SpawnType.ENEMY)
	_clear_gridmap_devhints(SpawnType.TOWER)
	
	navmap.bake_navigation_mesh(true)


func _spawn(spawn_type: SpawnType):
	var devhint = _find_gridmap_devhint(spawn_type)
	var spawn_nodes = _find_cells(devhint)
	var random_spawn = spawn_nodes.pick_random()
	return _make_global(random_spawn)
	
func _make_global(cell_pos) -> Vector3:
	return gridmap.to_global(gridmap.map_to_local(cell_pos))
	
func _find_gridmap_devhint(spawntype: SpawnType) -> int:
	print(gridmap.mesh_library.get_item_list())
	return gridmap.mesh_library.find_item_by_name(_spawn_name[spawntype])

func _find_cells(devhint_id: int) -> Array[Vector3i]:
	return gridmap.get_used_cells_by_item(devhint_id)
	
func _remove_gridmap_devhint(local_cell_pos):
	if debug_hints == false:
		gridmap.set_cell_item(local_cell_pos,-1,0)
	
func _clear_gridmap_devhints(spawntype: SpawnType):
	var hint = _find_gridmap_devhint(spawntype)
	for s in _find_cells(hint):
		_remove_gridmap_devhint(s)
