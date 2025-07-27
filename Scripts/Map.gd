extends Node3D
class_name Map



@export var debug_hints:bool = false
@export var gridmap:GridMap

var towerspawn = "TowerSpawnDev"
var playerspawn = "PlayerSpawnDev"
var enemyspawn = "EnemySpawnDev"

@onready var player = $Player
@onready var enemy = $Enemy
@onready var tower = $Tower

func _ready() -> void:
	player.position = player.spawn_pos
	enemy.position = enemy.spawn_pos
	tower.position = tower.spawn_pos
	
	print("Player spawn: ", player.spawn_pos)
	print("Enemy spawn: ", enemy.spawn_pos)
	print("Tower spawn: ", tower.spawn_pos)
	
## [param hintname] hint
func find_gridmap_devhints(spawntype: String) -> int:
	print(gridmap.mesh_library.get_item_list())
	return gridmap.mesh_library.find_item_by_name(spawntype)
	
func find_cells(devhint_id) -> Array[Vector3i]:
	return gridmap.get_used_cells_by_item(devhint_id)

func remove_gridmap_devhint(local_cell_pos):
	if debug_hints == false:
		gridmap.set_cell_item(local_cell_pos,-1,0)

func make_global(cell_pos) -> Vector3:
	return gridmap.to_global(gridmap.map_to_local(cell_pos))
