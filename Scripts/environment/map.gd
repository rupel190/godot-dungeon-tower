extends Node3D
class_name Map

enum SpawnType {
	PLAYER,
	ENEMY,
	TOWER
}

var ENEMY_ENTITY = preload("res://Scenes/Entities/Characters/Enemy.tscn")
var TOWER_ENTITY = preload("res://Scenes/Entities/Structures/SmallTower.tscn")

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
@onready var _enemy_container = $EnemyContainer
@onready var _tower_container = $TowerContainer

func _ready() -> void:
	_player.position = _calc_spawn_pos(SpawnType.PLAYER)
	
	spawn_tower()
	spawn_tower()
	spawn_tower()
	
	spawn_enemy()
	spawn_enemy()
	
	# Clear the rest
	#_clear_gridmap_devhints(SpawnType.PLAYER)
	#_clear_gridmap_devhints(SpawnType.ENEMY)
	#_clear_gridmap_devhints(SpawnType.TOWER)
	
	navmap.bake_navigation_mesh(true)
	
	
func spawn_enemy():
	var pos = _calc_spawn_pos(SpawnType.ENEMY)
	if pos:
		print("Spawning new enemy at ", pos)
		var en: Enemy = ENEMY_ENTITY.instantiate()
		en.position = pos
		_enemy_container.add_child(en)
		SignalBus.enemy_spawned.emit()

# Duplicated for simplicity
func spawn_tower():
	var pos = _calc_spawn_pos(SpawnType.TOWER)
	if pos:
		print("Spawning new tower at ", pos)
		var tower: Node3D = TOWER_ENTITY.instantiate()
		tower.position = pos
		tower.position.y = 0
		tower.add_to_group("SmallTower")
		_tower_container.add_child(tower)
	
	
func _calc_spawn_pos(spawn_type: SpawnType):
	var devhint = _find_gridmap_devhint(spawn_type)
	var spawn_nodes = _find_cells(devhint)
	var random_spawn = spawn_nodes.pick_random()
	if random_spawn:
		_remove_gridmap_devhint(random_spawn)
		return _make_global(random_spawn)
	else:
		push_warning("Spawns exhausted!")

func _find_cells(devhint_id: int) -> Array[Vector3i]:
	return gridmap.get_used_cells_by_item(devhint_id)
	
func _remove_gridmap_devhint(local_cell_pos):
	if debug_hints == false:
		gridmap.set_cell_item(local_cell_pos, GridMap.INVALID_CELL_ITEM ,0)
	
func _find_gridmap_devhint(spawntype: SpawnType) -> int:
	print(gridmap.mesh_library.get_item_list())
	return gridmap.mesh_library.find_item_by_name(_spawn_name[spawntype])

func _clear_gridmap_devhints(spawntype: SpawnType):
	var hint = _find_gridmap_devhint(spawntype)
	for s in _find_cells(hint):
		_remove_gridmap_devhint(s)
		
func _make_global(cell_pos) -> Vector3:
	return gridmap.to_global(gridmap.map_to_local(cell_pos))
