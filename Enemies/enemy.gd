extends CharacterBody3D

@export var target_node : Node3D

const SPEED = 1
const ROT_SPEED = 3.0
const JUMP_VELOCITY = 4.5

const STOP_DISTANCE : float = 1
const MAX_HP : float = 50

var hp = MAX_HP

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var vector_to_target = target_node.position - self.position
	vector_to_target.y = 0 # remove vertical difference
	var direction = vector_to_target.normalized()
	# look at target
	var target_angle = atan2(-direction.z, direction.x) - deg_to_rad(90)
	rotation.y = lerp_angle(rotation.y, target_angle, delta * ROT_SPEED)
	# Move towards target
	if vector_to_target.length() > STOP_DISTANCE:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func on_hit(damage: float):
	hp -= damage
	if hp <= 0:
		self.queue_free()
