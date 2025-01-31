extends ManaObject
class_name ManaTurret

@export var cost : int = 10
@onready var mana_transit_pos = $ManaPoint.global_position
@export var max_mana := 20

var cur_mana := 6

@export var fire_range : float = 4.0
@export var fire_cost : int = 2
@export var fire_rate_per_sec : float = 1.6
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
		var targets : Array = range_area.get_overlapping_bodies()
		# remove invalid targets
		targets = targets.filter(func(e): return ((e is Enemy) and (e.hp - e.incoming_damage > 0)))
		if not targets.is_empty():
			var closest = targets[0]
			for target in targets:
				if (position.distance_squared_to(target.position) < position.distance_squared_to(closest.position)):
					closest = target
			# shoot
			shoot_at(closest)

var shots_fired : int = 0
func shoot_at(target : Enemy):
	cur_mana -= fire_cost
	var proj = projectile_res.instantiate()
	proj.setup(mana_transit_pos, target, damage)
	add_child(proj)
	target.incoming_damage += damage
	fire_cooldown = 1.0 / fire_rate_per_sec
	shots_fired += 1

func on_hit(damage_amt : int):
	cur_mana -= damage_amt
	if cur_mana <= -4:
		Singleton.network_manager.remove_mana_object(self)
		self.queue_free()

func get_requested_mana() -> int:
	return max_mana - cur_mana

func give_mana(amount : int):
	cur_mana += amount
