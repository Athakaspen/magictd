extends Node2D

var providers : Array[AStarNode]
var requesters : Array[AStarNode]

var AStar := AStar2D.new()
class AStarNode:
	var id : int
	var object : Node2D
	var max_range : float
var id_to_node_map : Dictionary

const packet_res = preload("res://mana_packet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var children = get_children()
	AStar.reserve_space(len(children))
	for child in children:
		var node = create_astar_node(child)
		if node.object.has_method("get_requested_mana"):
			requesters.append(node)
		if node.object.has_method("take_mana"):
			providers.append(node)
	
	print(AStar.get_id_path(1, 3))
	AStar.add_point(4, Vector2(0,0))
	print(AStar.get_id_path(1, 4))

func create_astar_node(object) -> AStarNode:
	var node = AStarNode.new()
	node.id = AStar.get_available_point_id()
	node.object = object
	if ("max_link_range" in object):
		node.max_range = object.max_link_range
	else:
		node.max_range = 10000
	id_to_node_map[node.id] = node
	
	AStar.add_point(node.id, node.object.global_position)
	link_objects_in_range(node)
	return node

func delete_astar_node(node : AStarNode):
	id_to_node_map[node.id] = null
	AStar.remove_point(node.id)

func link_objects_in_range(this : AStarNode):
	var nodes = id_to_node_map.values()
	for other in nodes:
		if (other.id != this.id):
			var dist_2 = AStar.get_point_position(this.id) \
				.distance_squared_to(AStar.get_point_position(other.id))
			if (this.id == 3):
				pass
			var max_range = min(this.max_range, other.max_range)
			if (dist_2 < max_range * max_range):
				AStar.connect_points(this.id, other.id)
				print("link " + str(this.id) + " to " + str(other.id))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	process_requests()
	
func process_requests():
	for req in requesters:
		if (req.object.get_requested_mana() > 0):
			for prov in providers:
				if !AStar.get_id_path(prov.id, req.id).is_empty():
					if (prov.object.get_available_mana() > 0):
						print(AStar.get_id_path(prov.id, req.id))
						prov.object.take_mana(1)
						send_packet(1, prov, req)

func send_packet(amount, origin, destination):
	var packet = packet_res.instantiate()
	packet.position = origin.object.position
	packet.mana_amount = amount
	packet.speed = 300.0
	var array : Array[Vector2]
	array.assign(AStar.get_point_path(origin.id, destination.id))
	packet.path_positions = array
	packet.destination_receiver = destination.object
	add_child(packet)
