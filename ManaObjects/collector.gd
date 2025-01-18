extends ManaObject
class_name ManaCollector

@export var mana_per_sec : float = 0.8
@export var SEND_COOLTIME := 0.2
var max_mana : int = 3
var cur_mana : int = 0
var wait_time := 1.0 / mana_per_sec
var paused : bool = false

var send_cooldown_time : float = 0

# position that mana packets should pass through
@onready var mana_transit_pos : Vector3 = $ManaPoint.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# mana sending
	send_cooldown_time -= delta
	
	# mana generation
	if paused: return
	wait_time -= delta
	if(wait_time < 0):
		cur_mana += 1
		wait_time = 1.0 / mana_per_sec
		if cur_mana >= max_mana:
			paused = true

func get_available_mana() -> int:
	if send_cooldown_time > 0: return 0
	return cur_mana

var mana_sent_count : int = 0
func take_mana(amount):
	if amount > cur_mana:
		push_error("Took too much mana!")
	cur_mana -= amount
	mana_sent_count += amount
	send_cooldown_time = SEND_COOLTIME
	if cur_mana < max_mana:
		paused = false
