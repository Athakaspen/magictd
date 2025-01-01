extends Node3D
class_name ManaObject

# Something like a template class
@export var max_range : float = 1.0
var network_id : int
var mana_transit_point : Vector3

var mana_transmitted_count : int = 0
func on_mana_pass(amount):
	mana_transmitted_count += amount
