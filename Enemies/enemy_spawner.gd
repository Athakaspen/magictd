extends Node3D
class_name EnemySpawner

@export var enemy_holder : Node3D
@export var seconds_between_spawns :float = 1.0
@export var random_shift :float = 0.5

var enabled = false

var time_til_next_spawn :float = seconds_between_spawns * (1 + random_shift)

const enemy_res = preload("res://Enemies/enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = enabled

func enable():
	enabled = true
	visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (enabled):
		time_til_next_spawn -= delta
		if time_til_next_spawn <= 0:
			spawn()
			time_til_next_spawn = seconds_between_spawns * (1 + (randf_range(-1, 1) * random_shift))

func spawn():
	var enemy = enemy_res.instantiate()
	enemy.mana_base = %Base
	var pos = $Marker3D.global_position + Vector3.FORWARD.rotated(Vector3.UP, randf_range(0.0, 6.28)) * 2.5
	enemy.position = pos
	enemy_holder.add_child(enemy)
