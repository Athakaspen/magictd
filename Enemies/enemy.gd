extends CharacterBody3D

@export var mana_base : ManaBase
var target_node : Node3D

const SPEED = 1
const ROT_SPEED = 3.0
const JUMP_VELOCITY = 4.5

const STOP_DISTANCE : float = 1
const MAX_HP : float = 50

const RETARGET_TIME = 0.59 # seconds
var time_to_next_retarget = RETARGET_TIME

var hp = MAX_HP

func _ready():
	retarget()

func retarget():
	var bodies : Array[Node3D] = $TargetingArea.get_overlapping_bodies()
	bodies.sort_custom(target_priority)
	if len(bodies) > 0:
		target_node = bodies[0].get_parent()
		if target_node is not ManaObject or target_node is ManaCollector:
			target_node = mana_base
	else:
		target_node = mana_base

func target_priority(a, b):
	# current target
	if a.get_parent() == target_node:
		return true
	if b.get_parent() == target_node:
		return false
	# base
	if a.get_parent() is ManaBase:
		return true
	if b.get_parent() is ManaBase:
		return false
	# turret
	if a.get_parent() is ManaTurret:
		return true
	if b.get_parent() is ManaTurret:
		return false
	# anything
	if a.get_parent() is ManaObject:
		return true
	if b.get_parent() is ManaObject:
		return false
	# fallback
	return a

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
	
	time_to_next_retarget -= delta
	if time_to_next_retarget <= 0:
		retarget()
		print(target_node)
		time_to_next_retarget = RETARGET_TIME

func on_hit(damage: float):
	hp -= damage
	if hp <= 0:
		self.queue_free()
