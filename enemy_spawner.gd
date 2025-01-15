extends Node3D

var seconds_between_spawns := 9.0
var random_shift := 5.0

var time_til_next_spawn := seconds_between_spawns + random_shift

const enemy_res = preload("res://Enemies/enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_til_next_spawn -= delta
	if time_til_next_spawn <= 0:
		spawn()
		time_til_next_spawn = seconds_between_spawns + randf_range(-1, 1) * random_shift

func spawn():
	var enemy = enemy_res.instantiate()
	enemy.target_node = %Base
	get_parent().add_child(enemy)
	var position = $Marker3D.global_position + Vector3.FORWARD.rotated(Vector3.UP, randf_range(0.0, 6.28)) * 2.5
	enemy.global_position = position
