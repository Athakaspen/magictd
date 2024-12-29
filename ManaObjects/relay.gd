extends ManaObject
class_name ManaRelay

# position that mana packets should pass through
@onready var mana_transit_pos : Vector3 = $ManaPoint.global_position

var mana_transmitted_count : int = 0

func on_mana_pass(amount):
	mana_transmitted_count += amount

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
