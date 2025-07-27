extends CharacterBody3D
class_name CharacterBase
signal on_hurt



@export var health:float = 100

var direction : Vector3 = Vector3.ZERO


func damage(amount:float):
	health -= amount
	on_hurt.emit()
	print(name, " was hurt an amount of: ",amount," HP")

func stair_step_down():
	if is_grounded:
		return

	# If we're falling from a step
	if velocity.y <= 0 and was_grounded:
		_debug_stair_step_down("SSD_ENTER", null)													## DEBUG

		# Initialize body test variables
		var body_test_result = PhysicsTestMotionResult3D.new()
		var body_test_params = PhysicsTestMotionParameters3D.new()

		body_test_params.from = self.global_transform			## We get the player's current global_transform
		body_test_params.motion = Vector3(0, MAX_STEP_DOWN, 0)	## We project the player downward

		if PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
			# Enters if a collision is detected by body_test_motion
			# Get distance to step and move player downward by that much
			position.y += body_test_result.get_travel().y
			apply_floor_snap()
			is_grounded = true
			_debug_stair_step_down("SSD_APPLIED", body_test_result.get_travel().y)					## DEBUG

# Function: Handle walking up stairs
func stair_step_up():
	if direction == Vector3.ZERO:
		return

	if velocity.y > 0:
		return

	_debug_stair_step_up("SSU_ENTER", null)															## DEBUG

	# 0. Initialize testing variables
	var body_test_params = PhysicsTestMotionParameters3D.new()
	var body_test_result = PhysicsTestMotionResult3D.new()

	var test_transform = global_transform				## Storing current global_transform for testing
	var distance = direction * 0.1						## Distance forward we want to check
	body_test_params.from = self.global_transform		## Self as origin point
	body_test_params.motion = distance					## Go forward by current distance

	_debug_stair_step_up("SSU_TEST_POS", test_transform)											## DEBUG

	# Pre-check: Are we colliding?
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		_debug_stair_step_up("SSU_EXIT_1", null)													## DEBUG

		## If we don't collide, return
		return

	# 1. Move test_transform to collision location
	var remainder = body_test_result.get_remainder()							## Get remainder from collision
	test_transform = test_transform.translated(body_test_result.get_travel())	## Move test_transform by distance traveled before collision

	_debug_stair_step_up("SSU_REMAINING", remainder)												## DEBUG
	_debug_stair_step_up("SSU_TEST_POS", test_transform)											## DEBUG

	# 2. Move test_transform up to ceiling (if any)
	var step_up = MAX_STEP_UP * vertical
	body_test_params.from = test_transform
	body_test_params.motion = step_up
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	_debug_stair_step_up("SSU_TEST_POS", test_transform)											## DEBUG

	# 3. Move test_transform forward by remaining distance
	body_test_params.from = test_transform
	body_test_params.motion = remainder
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	_debug_stair_step_up("SSU_TEST_POS", test_transform)											## DEBUG

	# 3.5 Project remaining along wall normal (if any)
	## So you can walk into wall and up a step
	if body_test_result.get_collision_count() != 0:
		remainder = body_test_result.get_remainder().length()

		### Uh, there may be a better way to calculate this in Godot.
		var wall_normal = body_test_result.get_collision_normal()
		var dot_div_mag = direction.dot(wall_normal) / (wall_normal * wall_normal).length()
		var projected_vector = (direction - dot_div_mag * wall_normal).normalized()

		body_test_params.from = test_transform
		body_test_params.motion = remainder * projected_vector
		PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
		test_transform = test_transform.translated(body_test_result.get_travel())

		_debug_stair_step_up("SSU_TEST_POS", test_transform)										## DEBUG

	# 4. Move test_transform down onto step
	body_test_params.from = test_transform
	body_test_params.motion = MAX_STEP_UP * -vertical

	# Return if no collision
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		_debug_stair_step_up("SSU_EXIT_2", null)													## DEBUG

		return

	test_transform = test_transform.translated(body_test_result.get_travel())
	_debug_stair_step_up("SSU_TEST_POS", test_transform)											## DEBUG

	# 5. Check floor normal for un-walkable slope
	var surface_normal = body_test_result.get_collision_normal()

	if STEP_UP_DEBUG:
		print("SSU: Surface check: ", snappedf(surface_normal.angle_to(vertical), 0.001), " vs ", floor_max_angle)#!
	if (snappedf(surface_normal.angle_to(vertical), 0.001) > floor_max_angle):
		_debug_stair_step_up("SSU_EXIT_3", null)													## DEBUG

		return

	if STEP_UP_DEBUG:
		print("SSU: Walkable")#!
	_debug_stair_step_up("SSU_TEST_POS", test_transform)											## DEBUG

	# 6. Move player up
	var global_pos = global_position
	var step_up_dist = test_transform.origin.y - global_pos.y
	_debug_stair_step_up("SSU_APPLIED", step_up_dist)												## DEBUG

	velocity.y = 0
	global_pos.y = test_transform.origin.y
	global_position = global_pos


#endregion

#region DEBUG ####################################################################################

# Debug: Stair Step Down
func _debug_stair_step_down(param, value):
	if STEP_DOWN_DEBUG == false:
		return

	match param:
		"SSD_ENTER":
			print()
			print("Stair step down entered")
		"SSD_APPLIED":
			print("Stair step down applied, travel = ", value)

# Debug: Stair Step Up
func _debug_stair_step_up(param, value):
	if STEP_UP_DEBUG == false:
		return

	match param:
		"SSU_ENTER":
			print()
			print("SSU: Stair step up entered")
		"SSU_EXIT_1":
			print("SSU: Exited with no collisions")
		"SSU_TEST_POS":
			print("SSU: test_transform current position = ", value)
		"SSU_REMAINING":
			print("SSU: Remaining distance = ", value)
		"SSU_EXIT_2":
			print("SSU: Exited due to no step collision")
		"SSU_EXIT_3":
			print("SSU: Exited due to non-floor stepping")
		"SSU_APPLIED":
			print("SSU: Player moved up by ", value, " units")


#endregion
@export_category("Stair Stepping Settings")
var is_grounded:bool = false
var was_grounded:bool = false
const vertical := Vector3(0, 1, 0)		# Shortcut for converting vectors to vertical
const horizontal := Vector3(1, 0, 1)
## Max height body will go up stairs.
@export var MAX_STEP_UP := 0.5			# Maximum height in meters the player can step up.
## Max height body will go down stairs.
@export var MAX_STEP_DOWN := -0.5		# Maximum height in meters the player can step down.

## Set to [code]true[/code] for body to print debug info for upward calculations
@export var STEP_DOWN_DEBUG := false	# Enable these to get detailed info on the step down/up process.
## Set to [code]true[/code] for body to print debug info for downward calculations
@export var STEP_UP_DEBUG := false
@export var COLLIDER: CollisionShape3D

func _pre_physics_process():
	# Lock player collider rotation
	COLLIDER.global_rotation = Vector3.ZERO

	# Update player state
	was_grounded = is_grounded

	if is_on_floor():
		is_grounded = true
	else:
		is_grounded = false
