extends ManaObject
class_name ManaCollector

@export var mana_per_sec := 2
var max_mana : int = 1
var cur_mana : int = 0
var wait_time := 1.0 / mana_per_sec
var paused : bool = false

# position that mana packets should pass through
@onready var mana_transit_pos : Vector3 = $ManaPoint.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if paused: return
	wait_time -= delta
	if(wait_time < 0):
		cur_mana += 1
		wait_time = 1.0 / mana_per_sec
		if cur_mana >= max_mana:
			paused = true

func get_available_mana() -> int:
	return cur_mana

var mana_sent_count : int = 0
func take_mana(amount):
	if amount > cur_mana:
		push_error("Took too much mana!")
	cur_mana -= amount
	mana_sent_count += amount
	if cur_mana < max_mana:
		paused = false

var mana_transmitted_count : int = 0
func on_mana_pass(amount):
	mana_transmitted_count += amount
