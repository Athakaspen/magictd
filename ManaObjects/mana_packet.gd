extends Node3D

var network_manager : NetworkManager
var mana_amount : int
var speed : float = 1.5 # units per second
var destination_receiver : Object
var path_ids : PackedInt64Array

var cur_index : int = 0

func setup_data(network_manager : NetworkManager, mana_amount : int, path_ids : PackedInt64Array):
	self.network_manager = network_manager
	self.mana_amount = mana_amount
	self.path_ids = path_ids

# Called when the node enters the scene tree for the first time.
func _ready():
	var start_node : AStarNode = network_manager.get_astar_node(path_ids[0])
	self.global_position = start_node.pos
	cur_index = 1
	tween_to_next_position()

func tween_to_next_position():
	var next_node : AStarNode = network_manager.get_astar_node(path_ids[cur_index])
	var dist : float = position.distance_to(next_node.pos)
	var tween = create_tween()
	tween.tween_property(self, "position", next_node.pos, dist / speed)
	tween.tween_callback(end_tween)

func end_tween():
	cur_index += 1
	if (cur_index < len(path_ids)):
		tween_to_next_position()
	else:
		var end_node : AStarNode = network_manager.get_astar_node(path_ids[-1])
		end_node.obj.give_mana(mana_amount)
		print("given")
		self.queue_free()
