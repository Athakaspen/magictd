class_name WaveData

var name : String
var duration : int
var enemy_count : int

func _init(wave_name: String, wave_duration: int, enemies: int):
	name = wave_name
	duration = wave_duration
	enemy_count = enemies
