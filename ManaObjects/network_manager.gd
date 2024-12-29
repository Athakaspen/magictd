extends Node3D
class_name NetworkManager

var providers : Array[AStarNode]
var requesters : Array[AStarNode]

var AStar := AStar3D.new()
var id_to_node_map : Dictionary

@export var debug_lines : bool = true

const base_res = preload("res://ManaObjects/base.tscn")
const relay_res = preload("res://ManaObjects/relay.tscn")
const collector_res = preload("res://ManaObjects/collector.tscn")
const packet_res = preload("res://ManaObjects/mana_packet.tscn")

func get_astar_node(id:int) -> AStarNode:
	var result = id_to_node_map[id]
	if id_to_node_map[id] == null:
		push_error("Unknown ID!")
	return result

# Called when the node enters the scene tree for the first time.
func _ready():
	var children = get_children()
	#AStar.reserve_space(len(children))
	for child in children:
		if child is ManaObject:
			var node = create_astar_node(child)
			if node.obj.has_method("get_requested_mana"):
				requesters.append(node)
			if node.obj.has_method("take_mana"):
				providers.append(node)

func add_mana_object(type, new_pos : Vector3):
	var new_obj : Node3D
	if (type == ManaBase):
		new_obj = base_res.instantiate()
	elif (type == ManaRelay):
		new_obj = relay_res.instantiate()
	elif (type == ManaCollector):
		new_obj = collector_res.instantiate()
	else:
		push_error("Expected a mana object!")
	new_obj.position = new_pos
	add_child(new_obj)
	var node = create_astar_node(new_obj)
	if node.obj.has_method("get_requested_mana"):
		requesters.append(new_obj)
	if node.obj.has_method("take_mana"):
		providers.append(new_obj)

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
	
	var pos
	if "mana_transit_pos" in object:
		pos = object.mana_transit_pos
	else:
		pos = object.global_position
	node.pos = pos
	AStar.add_point(node.id, pos)
	link_objects_in_range(node)
	return node

func delete_astar_node(node : AStarNode):
	id_to_node_map[node.id] = null
	AStar.remove_point(node.id)

func link_objects_in_range(this : AStarNode):
	var nodes = id_to_node_map.values()
	for other in nodes:
		if (other.id != this.id):
			var p_this = AStar.get_point_position(this.id)
			var p_other = AStar.get_point_position(other.id)
			var dist_2 = p_this.distance_squared_to(p_other)
			var max_range = min(this.max_range, other.max_range)
			if (dist_2 < max_range * max_range):
				# collision check
				var space_state = get_world_3d().direct_space_state
				var raycast = PhysicsRayQueryParameters3D.create(p_other, p_this, Layers.GEOMETRY_LAYER + Layers.OBJECT_LAYER)
				var collision = space_state.intersect_ray(raycast)
				if !collision:
					AStar.connect_points(this.id, other.id)
					#print("link " + str(this.id) + " to " + str(other.id))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	process_requests()

func sort_time(a : AStarNode, b : AStarNode):
	if (a.last_used_time < b.last_used_time):
		return true
	return false


func process_requests():
	requesters.sort_custom(sort_time)
	for req in requesters:
		if (req.obj.get_requested_mana() > 0):
			#providers.sort_custom(sort_time)
			for prov in providers:
				if !AStar.get_id_path(prov.id, req.id).is_empty():
					if (prov.obj.get_available_mana() > 0):
						#print(AStar.get_id_path(prov.id, req.id))
						prov.obj.take_mana(1)
						send_packet(1, prov, req)
						req.last_used_time = Time.get_unix_time_from_system()
						prov.last_used_time = Time.get_unix_time_from_system()

func send_packet(amount, origin, destination):
	var packet = packet_res.instantiate()
	packet.setup_data(self, amount, AStar.get_id_path(origin.id, destination.id))
	#packet.position = origin.pos
	#packet.speed = 1.5
	add_child(packet)
