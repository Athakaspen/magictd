extends Node3D
class_name NetworkManager

var providers : Array[AStarNode]
var requesters : Array[AStarNode]

var AStar := AStar3D.new()
var id_to_node_map : Dictionary

const packet_res = preload("res://ManaObjects/mana_packet.tscn")

func get_astar_node(id:int) -> AStarNode:
	var result = id_to_node_map[id]
	if id_to_node_map[id] == null:
		push_error("Unknown ID!")
	return result

# Called when the node enters the scene tree for the first time.
func _ready():
	var children = get_children()
	AStar.reserve_space(len(children))
	for child in children:
		var node = create_astar_node(child)
		if node.obj.has_method("get_requested_mana"):
			requesters.append(node)
		if node.obj.has_method("take_mana"):
			providers.append(node)

func create_astar_node(object) -> AStarNode:
	var node = AStarNode.new()
	node.id = AStar.get_available_point_id()
	object.network_id = node.id
	node.obj = object
	id_to_node_map[node.id] = node
	
	if ("max_range" in object):
		node.max_range = object.max_range
	else:
		node.max_range = 10000
	
	var position
	if "mana_transit_pos" in object:
		position = object.mana_transit_pos
	else:
		position = object.global_position
	node.pos = position
	AStar.add_point(node.id, position)
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
			var max_range = min(this.max_range, other.max_range)
			if (dist_2 < max_range * max_range):
				AStar.connect_points(this.id, other.id)
				print("link " + str(this.id) + " to " + str(other.id))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	process_requests()
	
func process_requests():
	for req in requesters:
		if (req.obj.get_requested_mana() > 0):
			for prov in providers:
				if !AStar.get_id_path(prov.id, req.id).is_empty():
					if (prov.obj.get_available_mana() > 0):
						print(AStar.get_id_path(prov.id, req.id))
						prov.obj.take_mana(1)
						send_packet(1, prov, req)

func send_packet(amount, origin, destination):
	var packet = packet_res.instantiate()
	packet.setup_data(self, amount, AStar.get_id_path(origin.id, destination.id))
	#packet.position = origin.pos
	#packet.speed = 1.5
	add_child(packet)
