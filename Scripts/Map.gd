extends Node3D
class_name Map

@export var debug_hints:bool = false
@export var gridmap:GridMap
const tower_spawn_hintname:String = "TowerSpawnDev"
const player_spawn_hintname:String = "PlayerSpawnDev"
const enemy_spawn_hintname:String= "EnemySpawnDev"


#CACHE
var player_spawn_positions:Array[Vector3]
var tower_spawn_positions:Array[Vector3]
var enemy_spawn_positions:Array[Vector3]


# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	initialize_spawns()
func initialize_spawns():
	find_and_remove_gridmap_devhints(player_spawn_hintname,"add_player_spawn")
	find_and_remove_gridmap_devhints(tower_spawn_hintname,"add_tower_spawn")
	find_and_remove_gridmap_devhints(enemy_spawn_hintname,"add_enemy_spawn")
func find_and_remove_gridmap_devhints(hintname:String = player_spawn_hintname,hint_function:String = "add_player_spawn"):
	print(gridmap.mesh_library.get_item_list())
	var hint_id:int = gridmap.mesh_library.find_item_by_name(hintname)
	
	for cell_pos in gridmap.get_used_cells_by_item(hint_id):
		#CLEAR THE HINT.
		if debug_hints == false:
			gridmap.set_cell_item(cell_pos,-1,0)
		var global_cell_pos:Vector3 = gridmap.to_global(gridmap.map_to_local(cell_pos))
		call(hint_function,global_cell_pos)
func add_player_spawn(global_pos:Vector3):
	player_spawn_positions.append(global_pos)
func add_enemy_spawn(global_pos:Vector3):
	enemy_spawn_positions.append(global_pos)
func add_tower_spawn(global_pos:Vector3):
	enemy_spawn_positions.append(global_pos)



func _ready() -> void:
	
	
	pass
