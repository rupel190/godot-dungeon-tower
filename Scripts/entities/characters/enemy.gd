class_name Enemy
extends CharacterBody3D

signal died
signal damaged

@export var health: Health

@export var atk_dmg: int = 100
@export var atk_charge_duration: float = 1.8
@export var atk_cadence: float = 5.0	# cooldown start value
@export var atk_cooldown: float = 0.0
@export var move_speed: float = 4.0

var aggro_target: Node3D = null
var _aggro_update_timeout = 0	# calculated with delta
var max_pursuit_distance: float = 10.0
var max_stamina: float = 10.0
var min_stamina: float = 2.0
var stamina: float = max_stamina:
	set(value):
		stamina = clamp(value, min_stamina, max_stamina)
		if stamina <= min_stamina:
			stamina = max_stamina
			
var current_speed: float:
	get:
		return move_speed * get_stamina_percent()
var movement: Vector3 = Vector3.ZERO

@onready var nav_agent: NavigationAgent3D = $NavAgent
@onready var model: Node3D = $Model
@onready var mesh = $Model/Armature/Skeleton3D/Spook
@onready var _sfx_dmg = $SfxTakeDmg
@onready var _sfx_atk = $SfxAttack
@onready var main_tower: Node3D = $"../MainTower"
@onready var _atk_charge_timer := $AtkCharge
@onready var _atk_range := $AttackRange


func _ready() -> void:
	health.damaged.connect(damaged.emit)
	health.died.connect(SignalBus.enemy_destroyed.emit)
	_atk_range.body_entered.connect(_body_entered_atk_range)
	nav_agent.avoidance_enabled = true
	wall_min_slide_angle = 0

func _process(delta: float) -> void:
	# Periodic aggro update
	_aggro_update_timeout += delta
	if _aggro_update_timeout > 2:
		_aggro_update_timeout = 0
		_update_aggro()

	# Check for attacking
	if atk_cooldown > 0:
		atk_cooldown -= delta
			
func _physics_process(delta: float) -> void:
	stamina -= delta

	_calc_movement(aggro_target)
	velocity = movement + get_gravity()
	model.global_basis = model.global_basis.slerp(
		model.global_basis.looking_at(get_real_velocity() + Vector3.ONE * 0.1, Vector3.UP, true),
		delta * 3
	)
	move_and_slide()

func take_damage(from: Node3D, dmg: int):
	print("I AM ENEMY. DAMAGED BY: %s | DMG: %d" % [from.name, dmg])
	mesh.set_blend_shape_value(mesh.find_blend_shape_by_name("EYES_CLOSE"), -1)
	_sfx_take_dmg()
	aggro_target = from
	health.apply_damage(dmg)
	
	
func _body_entered_atk_range(body: Node3D):
	if body is Player or body is Tower:
		_initiate_attack()

func _initiate_attack():
	print("initiate attack")
	_atk_charge_timer.start(atk_charge_duration)
	_atk_charge_timer.timeout.connect(_attack)

func _attack():
	print("Enemy executing AoE.")
	atk_cooldown = atk_cadence
	mesh.set_blend_shape_value(mesh.find_blend_shape_by_name("EYES_CLOSE"), 1.0)
	_sfx_atk.play()
	
	var potential_targets: Array[Node3D] = _atk_range.get_overlapping_bodies()
	for t in potential_targets:
		if t.has_method("take_damage"):
			t.take_damage(atk_dmg)


func _calc_movement(target: Node3D):
	if target:
		nav_agent.target_position = target.global_position
		movement = (nav_agent.get_next_path_position() - global_position).normalized() * current_speed
		movement.y = 0

func get_stamina_percent() -> float:
	return smoothstep(0, max_stamina, stamina)

func _update_aggro():
	print("Update aggro state")
	if is_instance_valid(aggro_target):
		var dist = global_position.distance_to(aggro_target.global_position)
		if not aggro_target or dist > max_pursuit_distance:
			aggro_target = _updated_aggro_target()
			print("Switching aggro to: ", aggro_target, aggro_target.name)


func _updated_aggro_target():
	var closest_small_tower = find_closest_small_tower()
	if closest_small_tower:
		print("Targeting small tower: ", closest_small_tower.name)
		return closest_small_tower
	else:
		print("Targeting main tower: ", main_tower.name)
		return main_tower

func find_closest_small_tower() -> Node3D:
	var towers = get_tree().get_nodes_in_group("SmallTower")
	var closest: Node3D = null
	var closest_dist: float = INF

	for tower in towers:
		var dist = global_position.distance_to(tower.global_position)
		if dist < closest_dist:
			closest = tower
			closest_dist = dist

	return closest


func _sfx_take_dmg():
	_sfx_dmg.play()
