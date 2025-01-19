extends ManaObject
class_name ManaBase

@onready var mana_transit_pos : Vector3 = $ManaPoint.global_position
@export var max_mana := 10
@export var mana_out_per_sec := 10
@export var innate_mana_per_sec := 1.0
var cur_mana := 0

var send_cooldown_time : float = 0

var time_to_next_mana = 1.0 / innate_mana_per_sec
func _process(delta):
	send_cooldown_time -= delta
	time_to_next_mana -= delta
	if (time_to_next_mana <= 0) and (cur_mana < max_mana):
		cur_mana += 1
		time_to_next_mana = 1.0 / innate_mana_per_sec

# Requester functions
func get_requested_mana() -> int:
	return max_mana - cur_mana

func give_mana(amount : int):
	cur_mana += amount

# Provider functions (disabled)
func get_available_mana() -> int:
	if send_cooldown_time > 0: return 0
	return cur_mana

var mana_sent_count : int = 0
func _take_mana(amount):
	if amount > cur_mana:
		push_error("Took too much mana!")
	cur_mana -= amount
	mana_sent_count += amount
	send_cooldown_time = 1.0 / mana_out_per_sec

func on_hit(damage:int):
	cur_mana -= damage
	if cur_mana <= -4:
		visible = false
		Singleton.game_over()
