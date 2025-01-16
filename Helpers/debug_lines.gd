extends MeshInstance3D

@onready var network_manager : NetworkManager = %NetworkManager

var num_points := 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if network_manager.debug_lines:
		var AStar = network_manager.AStar
		
		# If no change, skip updating
		#if num_points == AStar.get_point_count():
			#return
		num_points = AStar.get_point_count()
		
		# Draw
		mesh.clear_surfaces()
		mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		var checkedPoints : Array
		for p1 in AStar.get_point_ids():
			for p2 in AStar.get_point_connections(p1):
				if p2 not in checkedPoints:
					# new line
					mesh.surface_add_vertex(AStar.get_point_position(p1))
					mesh.surface_add_vertex(AStar.get_point_position(p2))
			checkedPoints.append(p1)
		mesh.surface_end()
