extends Node3D
class_name WaveManager

var waves_dict : Dictionary = {
	3:		wave("Wave 1", 5),
	10:		wave("Wave 2", 2),
}

@export var wave_timer : Control

@export var TIME_SCALE = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#wave_timer.init_blocks(waves_dict)

var cur_time : float = 0
func _process(delta):
	cur_time += delta * TIME_SCALE
	wave_timer.update_timer(cur_time)

func wave(name, duration):
	return WaveData.new(name, duration)
