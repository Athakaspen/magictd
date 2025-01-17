extends Node3D
class_name ManaPacket

var network_manager : NetworkManager
var mana_amount : int
var speed : float = 5 # units per second
var destination_receiver : Object
var path_ids : PackedInt64Array

var cur_index : int = 0

func setup_data(net_manager : NetworkManager, mana_amt : int, path_ids_packedarray : PackedInt64Array):
	self.network_manager = net_manager
	self.mana_amount = mana_amt
	self.path_ids = path_ids_packedarray

# Called when the node enters the scene tree for the first time.
func _ready():
	var start_node : AStarNode = network_manager.get_astar_node(path_ids[0])
	self.global_position = start_node.pos
	cur_index = 1
	tween_to_next_position()

func tween_to_next_position():
	var next_node : AStarNode = network_manager.get_astar_node(path_ids[cur_index])
	if next_node == null:
		self.queue_free()
	else:
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
		if end_node != null:
			end_node.obj.give_mana(mana_amount)
		self.queue_free()

# Remove mana from en_route var when deleted
func _exit_tree():
	var dest = network_manager.get_astar_node(path_ids[-1])
	if dest != null:
		dest.mana_en_route -= mana_amount
