class_name Enemy
extends CharacterBody3D

signal died
signal damaged

@export var health: Health
@export var atk_dmg: int = 100
@export var atk_cadence: float = 5.0
@export var atk_range: float = 7.0
@export var move_speed: float = 4.0
var _atk_cooldown: float = 0.0

@onready var nav_agent: NavigationAgent3D = $NavAgent
@onready var model: Node3D = $Model
@onready var mesh = $Model/Armature/Skeleton3D/Spook
@onready var _sfx_dmg = $SfxTakeDmg
@onready var _sfx_atk = $SfxAttack
@onready var main_tower: Node3D = $"../MainTower"

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
var attack_target: Node3D = null
var aggro_target: Node3D = null

func _ready() -> void:
	health.damaged.connect(damaged.emit)
	health.died.connect(died.emit)
	nav_agent.avoidance_enabled = true
	wall_min_slide_angle = 0
	update_target()

func _physics_process(delta: float) -> void:
	stamina -= delta

	if _atk_cooldown > 0:
		_atk_cooldown -= delta
	elif is_instance_valid(attack_target):
		var distance = global_position.distance_to(attack_target.global_position)
		print("Enemy atk dist: ", distance)
		if distance <= atk_range:
			_attack()

	_check_target_distance()

	_calc_movement(attack_target)

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
	attack_target = from
	health.apply_damage(dmg)

func _attack():
	print("Enemy attacks: ", aggro_target)
	_atk_cooldown = atk_cadence
	_sfx_atk.play()
	mesh.set_blend_shape_value(mesh.find_blend_shape_by_name("EYES_CLOSE"), 1.0)
	if aggro_target and aggro_target.has_method("take_damage"):
		aggro_target.take_damage(atk_dmg)

func _sfx_take_dmg():
	_sfx_dmg.play()

func _calc_movement(target: Node3D):
	if target:
		nav_agent.target_position = target.global_position
		movement = (nav_agent.get_next_path_position() - global_position).normalized() * current_speed
		movement.y = 0

func get_stamina_percent() -> float:
	return smoothstep(0, max_stamina, stamina)

func _check_target_distance():
	if aggro_target and not is_instance_valid(aggro_target):
		aggro_target = null
		update_target()
		return

	if aggro_target:
		var dist = global_position.distance_to(aggro_target.global_position)
		if dist > max_pursuit_distance:
			print("Lost aggro on: ", aggro_target.name)
			aggro_target = null
			update_target()

func update_target():
	var closest_small_tower = find_closest_small_tower()
	if closest_small_tower:
		print("Targeting small tower: ", closest_small_tower.name)
		attack_target = closest_small_tower
	else:
		print("Targeting main tower: ", main_tower.name)
		attack_target = main_tower

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
