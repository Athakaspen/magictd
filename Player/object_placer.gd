extends Node3D

@onready var network_manager : NetworkManager = $"..".network_manager
@onready var placement_raycast : RayCast3D = $"../RotationHelper/PlacementRaycast"

var next_to_place = "relay"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_visibility(next_to_place)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if placement_raycast.is_colliding():
		var placement_point = placement_raycast.get_collision_point()
		$preview.global_position = placement_point
	else:
		$preview.global_position = Vector3(0, 0, -100)
	
	# do placement
	if Input.is_action_just_pressed("place_item"):
		if network_manager.get_base_mana() >= get_cost(next_to_place):
			network_manager.take_base_mana(get_cost(next_to_place))
			placement_raycast.force_raycast_update()
			if placement_raycast.is_colliding():
				var placement_point = placement_raycast.get_collision_point()
				match(next_to_place):
					"relay":
						network_manager.add_mana_object(ManaRelay, placement_point)
					"turret":
						network_manager.add_mana_object(ManaTurret, placement_point)

func cycle_next_to_place():
	match(next_to_place):
		"relay":
			next_to_place = "turret"
		"turret":
			next_to_place = "relay"
	set_visibility(next_to_place)
	Singleton.cur_cost = get_cost(next_to_place)

func set_visibility(objectStr: String):
	$preview/relay.visible = objectStr == "relay"
	$preview/turret.visible = objectStr == "turret"

func get_cost(objectStr):
	match(objectStr):
		"relay": 
			return 4
		"turret": 
			return 10
