extends Node3D
class_name Map

@export var debug_hints:bool = false
@export var gridmap:GridMap

const spawn_hints:Array[String] = ["PlayerSpawnDev","TowerSpawnDev","EnemySpawnDev"]


#CACHE
var spawns:Dictionary[String,Array]

# Called when the node enters the scene tree for the first time.

func initialize_spawns():
	for hint in spawn_hints:
		find_and_remove_gridmap_devhints(hint,"add_spawn")
func find_and_remove_gridmap_devhints(hintname:String = spawn_hints[0],hint_function:String = "add_spawn"):
	var hint_id:int = gridmap.mesh_library.find_item_by_name(hintname)
	for cell_pos in gridmap.get_used_cells_by_item(hint_id):
		#CLEAR THE HINT.
		if debug_hints == false:
			gridmap.set_cell_item(cell_pos,-1,0)
		var global_cell_pos:Vector3 = gridmap.to_global(gridmap.map_to_local(cell_pos))
		call(hint_function,hintname,global_cell_pos)
func add_spawn(hint_type:String,global_pos:Vector3):
	if spawns.has(hint_type) == false:
		spawns[hint_type] = []
	spawns[hint_type].append(global_pos)

func _ready() -> void:
	initialize_spawns()
