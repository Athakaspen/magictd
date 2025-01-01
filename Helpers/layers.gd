extends Node

var GEOMETRY_LAYER: int
var OBJECT_LAYER: int
var PLAYER_LAYER: int
var ENEMY_LAYER: int
var PROJECTILE_LAYER: int

func _init():
	for i in 32:
		var layer: String = ProjectSettings.get(str("layer_names/3d_physics/layer_", i + 1))
		if layer == "Geometry":
			@warning_ignore("narrowing_conversion")
			GEOMETRY_LAYER = pow(2, i)
		elif layer == "Object":
			@warning_ignore("narrowing_conversion")
			OBJECT_LAYER = pow(2, i)
		elif layer == "Player":
			@warning_ignore("narrowing_conversion")
			PLAYER_LAYER = pow(2, i)
		elif layer == "Enemy":
			@warning_ignore("narrowing_conversion")
			ENEMY_LAYER = pow(2, i)
		elif layer == "Projectile":
			@warning_ignore("narrowing_conversion")
			PROJECTILE_LAYER = pow(2, i)

	assert(GEOMETRY_LAYER and OBJECT_LAYER and PLAYER_LAYER and ENEMY_LAYER and PROJECTILE_LAYER)
