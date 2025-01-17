extends ManaObject
class_name ManaTurret

@export var cost : int = 10
@onready var mana_transit_pos = $ManaPoint.global_position
@export var max_mana := 100
var cur_mana := 0

@export var fire_range : float = 4.0
@export var fire_cost : int = 2
@export var fire_rate_per_sec : float = 0.8
@export var damage : float = 10.0

var projectile_res = preload("res://ManaObjects/Projectile.tscn")

var fire_cooldown : float = 0

@onready var range_area = $RangeArea

# Called when the node enters the scene tree for the first time.
func _ready():
	# set up range area
	range_area.get_node("CollisionShape3D").shape.radius = fire_range

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fire_cooldown -= delta
	if fire_cooldown <= 0 and cur_mana >= fire_cost:
		# acquire target
		var targets = range_area.get_overlapping_bodies()
		if not targets.is_empty():
			var closest = targets[0]
			for target in targets:
				if (position.distance_squared_to(target.position) < position.distance_squared_to(closest.position)):
					closest = target
			# shoot
			shoot_at(closest)

var shots_fired : int = 0
func shoot_at(target : Node3D):
	cur_mana -= fire_cost
	var proj = projectile_res.instantiate()
	proj.setup(mana_transit_pos, target, damage)
	add_child(proj)
	fire_cooldown = 1.0 / fire_rate_per_sec
	shots_fired += 1

func on_hit(damage:int):
	cur_mana -= damage
	if cur_mana <= -10:
		Singleton.network_manager.remove_mana_object(self)
		self.queue_free()

func get_requested_mana() -> int:
	return max_mana - cur_mana

func give_mana(amount : int):
	cur_mana += amount
