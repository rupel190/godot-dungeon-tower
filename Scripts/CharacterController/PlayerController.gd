class_name Player extends CharacterBase
signal awaiting_nod
signal just_nodded(answer:bool)
signal on_positive_nod
signal on_negative_nod
signal nod_value


@export var hands:PlayerHands
@export_category("Player Settings")
@export var crouch_height:float = 0.1
@export var Crouch_Speed : float = 0.3
@export var Move_Speed : float = 1.5
@export var Sprint_Speed : float = 10.0

@export var crouch_fov_mult:float = 0.75
@export var move_fov_mult:float = 1
@export var sprint_fov_mult:float = 1.2


var sprint_fov:float:
	get:
		return sprint_fov_mult * UserPrefs.base_fov
var move_fov:float:
	get:
		return move_fov_mult * UserPrefs.base_fov
var crouch_fov:float:
	get:
		return crouch_fov_mult * UserPrefs.base_fov

@export var PlayerInventory : Array[Dictionary] = []

@export_category("Inputs")

@export var InputDictionary : Dictionary = {
	"Forward": "ui_up",
	"Backward": "ui_down",
	"Left": "ui_left",
	"Right": "ui_right",
	"Jump": "ui_accept",
	"Escape": "ui_cancel",
	"Sprint": "ui_accept",
	"Interact": "ui_accept"
}


@export_category("Camera Settings")
@export_range(0.0, 1.0) var TiltThreshhold : float = 0.2

# Onready
@onready var head : Node3D = $Head
@onready var camera : Camera3D = $Head/Camera3D
@onready var ltilt : Marker3D = $Tilt/LTilt
@onready var rtilt : Marker3D = $Tilt/RTilt


# Vectors
var camera_manual_input:Vector2 =Vector2()
var camera_auto_input:Vector2 = Vector2()
var Rot_Vel : Vector2 = Vector2()


# Private
var _fov : float = move_fov
var _speed : float = Move_Speed

const JUMP_VELOCITY : float = 4.5
var default_head_height:float
var expected_nod_response:bool = false:
	set(value):
		if expected_nod_response != value:
			
			positive_nod_timer = 0
			negative_nod_timer = 0
			expected_nod_response = value
#this much time for nod. approx
var target_nod_time:float = 1.5
var positive_nod_timer:float = 0:
	set(value):
		positive_nod_timer = clamp(value,0,target_nod_time +0.1)
		if positive_nod_timer >= target_nod_time:
			print("player nodded positively")
			just_nodded.emit(true)
			on_positive_nod.emit()
			expected_nod_response = false
			positive_nod_timer = 0
var negative_nod_timer:float = 0:
	set(value):
		negative_nod_timer = clamp(value,0,target_nod_time +0.1)
		if negative_nod_timer >= target_nod_time:
			print(" player nodded negatively")
			just_nodded.emit(false)
			on_negative_nod.emit()
			expected_nod_response = false
			negative_nod_timer = 0


var lock_movement:bool = false

func _ready() -> void:
	default_head_height = head.position.y
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ltilt.rotation.z = TiltThreshhold
	rtilt.rotation.z = -TiltThreshhold

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_manual_input = event.relative
		if event.relative.length() > 1 and expected_nod_response:
			if abs(event.relative.x) >= abs(event.relative.y): 
				negative_nod_timer += get_physics_process_delta_time()
				positive_nod_timer -= get_physics_process_delta_time()
			else:
				positive_nod_timer += get_physics_process_delta_time()
				negative_nod_timer -= get_physics_process_delta_time()
		

func await_for_nod_response(head_target_v3:Node3D = null):
	expected_nod_response = true
	if head_target_v3 != null:
		head_lock_targets.append(head_target_v3)
	lock_movement = true
	print("waiting for player's answer...")
	awaiting_nod.emit()
	var answer:bool = await just_nodded
	lock_movement = false
	head_lock_targets.erase(head_target_v3)
	return answer


var head_lock_targets:Array[Node3D]
var camera_auto_turn_speed:float = 800
func calculate_camera_auto_input(target: Node3D):
	var to_target = (target.global_position - camera.global_position).normalized()
	var cam_forward = camera.global_basis.z
	#CALCULATIONS
	#YAW 
	var cross = cam_forward.cross(to_target)
	var yaw:float = cross.y
	#PITCH
	var local_dir = camera.global_transform.basis.transposed() * to_target
	var pitch:float = -asin(clamp(local_dir.y, -1.0, 1.0))
	#DEADZONE FOR JITTER FREE MOVEMENT.
	var deadzone:float = 0.01
	camera_auto_input.x = yaw * int(abs(yaw) >= deadzone)
	camera_auto_input.y = pitch * int(abs(pitch) >= deadzone)

func _update_head_transform(delta:float):
	# Camera Smooth look
	
	var should_lock:int = int(head_lock_targets.is_empty() == false)
	if should_lock == 1:
		calculate_camera_auto_input(head_lock_targets.front())
	
	var camera_input:Vector2 = camera_manual_input.slerp(camera_auto_input * camera_auto_turn_speed,delta * should_lock)
	
	Rot_Vel = Rot_Vel.lerp(camera_input * UserPrefs.mouse_sensitivity, delta * UserPrefs.mouse_smoothing)
	head.rotate_x(-deg_to_rad(Rot_Vel.y))
	rotate_y(-deg_to_rad(Rot_Vel.x))
	head.rotation.x = clamp(head.rotation.x, -1.5, 1.5)
	camera_manual_input = Vector2.ZERO
	camera_auto_input = Vector2.ZERO
	camera_tilt(delta)

func _physics_process(delta: float) -> void:
	
	
	_pre_physics_process()
	_update_head_transform(delta)
	
	if lock_movement == true:
		return
		
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	play_dynamic_footsteps()
	
	# Handle jump.
	if Input.is_action_just_pressed(InputDictionary["Jump"]) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	#	Modified standard input for smooth movements.
	var input_dir : Vector2 = Input.get_vector(InputDictionary["Left"], InputDictionary["Right"], InputDictionary["Forward"], InputDictionary["Backward"])
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized(), delta * 7.0)
	_speed = lerp(_speed, Move_Speed, min(delta * 5.0, 1.0))
	Sprint()
	Crouch()
	
	if direction:
		velocity.x = direction.x * _speed
		velocity.z = direction.z * _speed
	else:
		velocity.x = move_toward(velocity.x,0,_speed)
		velocity.z = move_toward(velocity.z,0,_speed)
	
	camera.fov = _fov
	
	stair_step_up()
	# Move
	move_and_slide()
	# Stair step down
	stair_step_down()

func Sprint() -> void:
	if Input.is_action_pressed(InputDictionary["Sprint"]) and Input.is_action_pressed("Crouch") == false:
		_speed = lerp(_speed, Sprint_Speed, 0.1)
		_fov = lerp(_fov, sprint_fov, 0.1)

func Crouch() -> void:
	if Input.is_action_pressed("Crouch"):
		_speed = lerp(_speed, Crouch_Speed, 0.1)
		_fov = lerp(_fov, crouch_fov, 0.1)
		head.position.y = lerpf(head.position.y,crouch_height,1)
	else:
		head.position.y = lerpf(head.position.y,default_head_height,1)
		_speed = lerp(_speed, Move_Speed, 0.1)
		_fov = lerp(_fov, move_fov, 0.1)

func camera_tilt(delta: float) -> void:
		#	Camera Tilt
	var target_tilt = 0.0
	if Input.is_action_pressed(InputDictionary["Left"]) and not Input.is_action_pressed(InputDictionary["Right"]):
		target_tilt = ltilt.rotation.z
	elif Input.is_action_pressed(InputDictionary["Right"]) and not Input.is_action_pressed(InputDictionary["Left"]):
		target_tilt = rtilt.rotation.z
	camera.rotation.z = lerp_angle(camera.rotation.z, target_tilt * int(!lock_movement), min(delta * 5.0, 1.0))


func play_dynamic_footsteps():
	var footstep_frequency: float = clamp(Vector2(get_real_velocity().x, get_real_velocity().z).length() / Sprint_Speed, 0.0, 1.0)
	$FootstepAudio.playing = footstep_frequency >= 0.1 and is_on_floor()
	$FootstepAudio.interval = lerpf(0.8, 0.1, footstep_frequency)
