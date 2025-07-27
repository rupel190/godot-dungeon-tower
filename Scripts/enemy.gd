extends CharacterBody3D

@onready var nav_agent:NavigationAgent3D = $NavAgent

@export var spawn_pos = Vector3i.ZERO
@export var map: Map
@onready var model:Node3D = $Model

var max_pursuit_distance:float = 5

var move_speed:float = 15
var max_stamina:float = 10
var min_stamina:float = 2
var stamina:float = max_stamina:
	set(value):
		
		stamina = clamp(value,min_stamina,max_stamina)
		if stamina <= min_stamina:
			stamina = max_stamina

var current_entity_target:Node3D
var main_tower:Node3D

var current_speed:float:
	get:
		return move_speed * get_stamina_percent()

var movement:Vector3
func _ready() -> void:
	
	$RandomSpawn.gridmap = map
	spawn_pos = $RandomSpawn._calc_random_spawn()
	
	nav_agent.avoidance_enabled = true
	wall_min_slide_angle = 0
	main_tower = get_tree().get_first_node_in_group("MainTower")

func _physics_process(delta: float) -> void:
	
	stamina -= delta
	detect_player_touch()
	find_way_to_target()
	velocity = movement + get_gravity()
	model.global_basis = model.global_basis.slerp(model.global_basis.looking_at(get_real_velocity() + Vector3.ONE * 0.1,Vector3.UP,true),delta * 3)
	move_and_slide()

func find_way_to_target():
	if current_entity_target != null:
		#FALLBACK.
		if current_entity_target.global_position.distance_to(global_position) > max_pursuit_distance:
			current_entity_target = main_tower
		
		nav_agent.target_position = current_entity_target.global_position
		movement = (nav_agent.get_next_path_position() - global_position).normalized() * current_speed
		movement.y = 0
	else:
		current_entity_target = main_tower

func detect_player_touch():
	
	if get_last_slide_collision() != null:
		var last_slide_collision:Node3D = get_last_slide_collision().get_collider()
		if last_slide_collision.is_in_group("Player"):
			current_entity_target = last_slide_collision
			print("Spooky enemy touched players butt")
			Gamemanager.gameover.emit("All the damage, player dead")



func get_stamina_percent():
	return smoothstep(0,max_stamina,stamina)
