extends CharacterBody3D


const SPEED = 5.0
const ROT_SPEED = 10
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.5
const JOY_SENSITIVIY = 5.0

const CAM_DIST_MIN = 1.5
const CAM_DIST_MAX = 4.0
const ZOOM_SPEED = 0.4

@export var network_manager : NetworkManager

@onready var rotation_helper = $RotationHelper
@onready var pivot = $CameraOrigin
@onready var camera_helper = $CameraOrigin/CameraHelper
@onready var spring_arm = $CameraOrigin/CameraHelper/SpringArm3D
@onready var camera = $CameraOrigin/CameraHelper/SpringArm3D/PlayerCamera

func _ready():
	print(Layers)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_helper.rotation.x = clamp(camera_helper.rotation.x, deg_to_rad(-60), deg_to_rad(-25))

func _input(event):
	if event is InputEventMouseMotion:
		rotate_camera(Vector2(-event.relative.x * MOUSE_SENSITIVITY, -event.relative.y * MOUSE_SENSITIVITY))

func rotate_camera(delta: Vector2):
	pivot.rotate_y(deg_to_rad(delta.x))
	camera_helper.rotate_x(deg_to_rad(delta.y))
	camera_helper.rotation.x = clamp(camera_helper.rotation.x, deg_to_rad(-70), deg_to_rad(-20))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Zoom
	if Input.is_action_just_pressed("zoom_in"):
		spring_arm.spring_length = clamp(spring_arm.spring_length - ZOOM_SPEED, CAM_DIST_MIN, CAM_DIST_MAX)
	elif Input.is_action_just_pressed("zoom_out"):
		spring_arm.spring_length = clamp(spring_arm.spring_length + ZOOM_SPEED, CAM_DIST_MIN, CAM_DIST_MAX)
	
	if Input.is_action_just_pressed("cycle_items"):
		$ObjectPlacer.cycle_next_to_place()
	
	# Uncapture mouse
	if Input.is_action_just_pressed("quit"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	rotate_camera(look_dir * JOY_SENSITIVIY)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		# look in movement direction
		rotation_helper.rotation.y = lerp_angle(rotation_helper.rotation.y, atan2(-direction.x, -direction.z), delta * ROT_SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
