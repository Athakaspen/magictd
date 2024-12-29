extends Node3D

@onready var network_manager : NetworkManager = $"..".network_manager
@onready var placement_raycast : RayCast3D = $"../RotationHelper/PlacementRaycast"

var relay_res = preload("res://ManaObjects/relay.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("place_item"):
		placement_raycast.force_raycast_update()
		if placement_raycast.is_colliding():
			var placement_point = placement_raycast.get_collision_point()
			network_manager.add_mana_object(ManaRelay, placement_point)
