extends CharacterBody3D
class_name Enemy

@export var mana_base : ManaBase
var target_node : Node3D

@export var SPEED = 1.5
@export var ROT_SPEED = 3.0
const JUMP_VELOCITY = 4.5

const STOP_DISTANCE : float = 0.75
@export var MAX_HP : float = 39

const RETARGET_TIME = 0.17 # seconds
var time_to_next_retarget = RETARGET_TIME

@export var ATTACK_DAMAGE : int = 2
@export var ATTACK_TIME : float = 2.0
@onready var time_to_next_attack = ATTACK_TIME

var hp : float = MAX_HP
var incoming_damage : float = 0

func _ready():
	retarget()

func _process(delta):
	time_to_next_retarget -= delta
	if time_to_next_retarget <= 0:
		retarget()
		time_to_next_retarget = RETARGET_TIME
	
	time_to_next_attack -= delta

func retarget():
	var bodies : Array[Node3D] = $TargetingArea.get_overlapping_bodies()
	bodies.sort_custom(target_priority)
	print(bodies)
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
	
	# base and turret
	if a.get_parent() is ManaBase or a.get_parent() is ManaTurret:
		if b.get_parent() is ManaBase or b.get_parent() is ManaTurret:
			# same priority, go by distance
			if global_position.distance_to(a.global_position) < global_position.distance_to(a.global_position):
				return true
			else:
				return false
		else:
			return true
	elif b.get_parent() is ManaBase or b.get_parent() is ManaTurret:
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
	
	if target_node == null:
		retarget()
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
		# arrived at target
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if time_to_next_attack <= 0:
			attack()
			time_to_next_attack = ATTACK_TIME
	move_and_slide()

func on_hit(damage: float):
	hp -= damage
	incoming_damage -= damage
	if hp <= 0:
		self.queue_free()

func attack():
	if "on_hit" in target_node:
		target_node.on_hit(ATTACK_DAMAGE)
