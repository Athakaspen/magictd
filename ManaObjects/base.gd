extends ManaObject
class_name ManaBase

@onready var mana_transit_pos : Vector3 = $ManaPoint.global_position
@export var max_mana := 10000
var cur_mana := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#$Label.text = "Mana: " + str(cur_mana)
	pass

func get_requested_mana() -> int:
	return max_mana - cur_mana

func give_mana(amount : int):
	cur_mana += amount
