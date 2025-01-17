extends Node3D
class_name NetworkManager

var providers : Array[AStarNode]
var requesters : Array[AStarNode]

var placement_point_id : int = 0

var AStar := AStar3D.new()
var id_to_node_map : Dictionary

@export var debug_lines : bool = true

const base_res = preload("res://ManaObjects/base.tscn")
const relay_res = preload("res://ManaObjects/relay.tscn")
const collector_res = preload("res://ManaObjects/collector.tscn")
const turret_res = preload("res://ManaObjects/Turret.tscn")

const packet_res = preload("res://ManaObjects/mana_packet.tscn")

func get_astar_node(id:int) -> AStarNode:
	var result = id_to_node_map.get(id)
	return result

# Called when the node enters the scene tree for the first time.
func _ready():
	Singleton.network_manager = self
	AStar.add_point(placement_point_id, Vector3.ZERO)
	AStar.set_point_disabled(placement_point_id, true)
	var children = get_children()
	for child in children:
		if child is ManaObject:
			var node = create_astar_node(child)
			if node.obj.has_method("get_requested_mana"):
				requesters.append(node)
			if node.obj.has_method("take_mana"):
				providers.append(node)

func add_mana_object(type, new_pos : Vector3):
	var new_obj : Node3D
	match(type):
		ManaBase:
			new_obj = base_res.instantiate()
		ManaRelay:
			new_obj = relay_res.instantiate()
		ManaCollector:
			new_obj = collector_res.instantiate()
		ManaTurret:
			new_obj = turret_res.instantiate()
		_:
			push_error("Expected a mana object!")
	new_obj.position = new_pos
	add_child(new_obj)
	var node = create_astar_node(new_obj)
	if node.obj.has_method("get_requested_mana"):
		requesters.append(node)
	if node.obj.has_method("take_mana"):
		providers.append(node)

func remove_mana_object(object: ManaObject):
	var node = get_astar_node(object.network_id)
	AStar.remove_point(node.id)
	requesters.erase(node)
	providers.erase(node)
	id_to_node_map.erase(node.id)

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
	for req : AStarNode in requesters:
		if (req.obj.get_requested_mana() - req.mana_en_route > 0):
			#providers.sort_custom(sort_time)
			for prov : AStarNode in providers:
				if req != prov and !AStar.get_id_path(prov.id, req.id).is_empty():
					if (prov.obj.get_available_mana() > 0):
						#print(AStar.get_id_path(prov.id, req.id))
						send_packet(1, prov, req)
						# whether to continue checking this requester
						if not (req.obj.get_requested_mana() - req.mana_en_route > 0):
							break

func send_packet(amount : int, origin : AStarNode, destination : AStarNode):
	origin.obj.take_mana(amount)
	var packet = packet_res.instantiate()
	packet.setup_data(self, amount, AStar.get_id_path(origin.id, destination.id))
	add_child(packet)
	origin.last_used_time = Time.get_unix_time_from_system()
	destination.last_used_time = Time.get_unix_time_from_system()
	destination.mana_en_route += amount

func get_base_mana() -> int:
	return %Base.cur_mana

func take_base_mana(amt: int):
	%Base.cur_mana -= amt

func update_placement_point(pos: Vector3):
	AStar.set_point_position(placement_point_id, pos)
	for id in AStar.get_point_ids():
		if id == placement_point_id: continue
		var p_other = AStar.get_point_position(id)
		var dist_2 = pos.distance_squared_to(p_other)
		var max_range = min(Singleton.cur_range * 0.98, get_astar_node(id).max_range)
		if (dist_2 < max_range * max_range):
			# collision check
			var space_state = get_world_3d().direct_space_state
			var raycast = PhysicsRayQueryParameters3D.create(p_other, pos, Layers.GEOMETRY_LAYER + Layers.OBJECT_LAYER)
			var collision = space_state.intersect_ray(raycast)
			if !collision:
				AStar.connect_points(placement_point_id, id)
			else:
				AStar.disconnect_points(placement_point_id, id)
		else:
			AStar.disconnect_points(placement_point_id, id)
		
