extends ManaObject
class_name ManaBase

@onready var mana_transit_pos : Vector3 = $ManaPoint.global_position
@export var max_mana := 10
@export var mana_out_per_sec := 10
var cur_mana := 0

var send_cooldown_time : float = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	send_cooldown_time -= delta

# Requester functions
func get_requested_mana() -> int:
	return max_mana - cur_mana

func give_mana(amount : int):
	cur_mana += amount

# Provider functions
func get_available_mana() -> int:
	if send_cooldown_time > 0: return 0
	return cur_mana

var mana_sent_count : int = 0
func take_mana(amount):
	if amount > cur_mana:
		push_error("Took too much mana!")
	cur_mana -= amount
	mana_sent_count += amount
	send_cooldown_time = 1.0 / mana_out_per_sec
