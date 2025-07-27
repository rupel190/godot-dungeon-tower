extends CSGCylinder3D

@export var spawn_pos = Vector3i.ZERO
@export var map: Map

func _ready() -> void:
	$RandomSpawn.gridmap = map
	spawn_pos = $RandomSpawn._calc_random_spawn()
	print("Set spawn pos to: ", spawn_pos, " for ", get_parent().name)
