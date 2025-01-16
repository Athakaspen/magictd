extends Node3D

@onready var network_manager : NetworkManager = $"..".network_manager
@onready var placement_raycast : RayCast3D = $"../RotationHelper/PlacementRaycast"

@onready var relay_instance : ManaRelay = preload("res://ManaObjects/relay.tscn").instantiate()
@onready var turret_instance : ManaTurret = preload("res://ManaObjects/Turret.tscn").instantiate()

var next_to_place : ManaObject

# Called when the node enters the scene tree for the first time.
func _ready():
	cycle_next_to_place()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if placement_raycast.is_colliding():
		var placement_point = placement_raycast.get_collision_point()
		$preview.global_position = placement_point
	else:
		$preview.global_position = Vector3(0, 0, -100)
	get_parent().network_manager.update_placement_point($preview.global_position + next_to_place.get_node("ManaPoint").position)
	
	# do placement
	if Input.is_action_just_pressed("place_item"):
		placement_raycast.force_raycast_update()
		if placement_raycast.is_colliding():
			var placement_point = placement_raycast.get_collision_point()
			if network_manager.get_base_mana() >= next_to_place.cost:
				network_manager.take_base_mana(next_to_place.cost)
				print(next_to_place)
				if next_to_place is ManaRelay:
					network_manager.add_mana_object(ManaRelay, placement_point)
				elif next_to_place is ManaTurret:
					network_manager.add_mana_object(ManaTurret, placement_point)

func cycle_next_to_place():
	if next_to_place == null: 
		next_to_place = relay_instance
	elif next_to_place is ManaRelay:
		next_to_place = turret_instance
	elif next_to_place is ManaTurret:
		next_to_place = relay_instance
	update_preview_visibility()
	Singleton.cur_cost = next_to_place.cost
	Singleton.cur_range = next_to_place.max_range

func update_preview_visibility():
	$preview/relay.visible = next_to_place is ManaRelay
	$preview/turret.visible = next_to_place is ManaTurret
