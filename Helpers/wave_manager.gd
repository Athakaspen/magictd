extends Node3D
class_name WaveManager

var waves_dict : Dictionary = {
	14:		wave("Wave 1", 2, 2),
	28:		wave("Wave 2", 4, 4),
	42:		wave("Wave 3", 4, 8),
	56:		wave("Wave 4", 6, 12),
	69:		wave("Final Wave", 10, 30),
}

var spawner_add_times : Array[int] = [0, 32]
var end_time = 80

@export var wave_timer : Control
@export var TIME_SCALE = 0.3

@export var spawners : Array[EnemySpawner]
var num_spawners : int = 0

var passive_spawn_rate = 0.1 # per second

var cur_time : float = 0
var cur_wave_block : int = floor(cur_time) - 1
var wave_blocks_left : int = 0
var cur_wave : WaveData = null
var game_won = false
func _process(delta):
	cur_time += delta * get_time_scale()
	wave_timer.update_timer(cur_time)
	
	# check win
	if game_won == false and ((cur_time >= end_time && $"../EnemyHolder".get_child_count() == 0) or cur_time > end_time + 30):
		Singleton.game_win()
		game_won = true
	
	if floor(cur_time) > cur_wave_block && cur_wave_block < end_time:
		cur_wave_block = floor(cur_time)
		if cur_wave_block >= end_time:
			for i in range(num_spawners):
				spawners[i].seconds_between_spawns = 10000
				spawners[i].time_til_next_spawn = 10000
			return
		if cur_wave_block in spawner_add_times:
			num_spawners += 1
			spawners[num_spawners-1].visible = true
		if waves_dict.get(cur_wave_block) != null:
			# new wave
			cur_wave = waves_dict[cur_wave_block]
			wave_blocks_left = cur_wave.duration
			# spawn rate of each spawner
			var spawn_rate = (float(cur_wave.enemy_count - 1) / float(num_spawners) / float(cur_wave.duration)) * get_spawn_scale()
			for i in range(num_spawners):
				spawners[i].enable()
				spawners[i].seconds_between_spawns = 1.0 / (spawn_rate * get_time_scale())
				spawners[i].random_shift = 0.1 * Singleton.cur_difficulty
				spawners[i].time_til_next_spawn = 0
		
		wave_blocks_left -= 1
		if wave_blocks_left < 0:
			# End of wave
			for i in range(num_spawners):
				spawners[i].enabled = false

func get_time_scale():
	if cur_time < waves_dict.keys().min():
		return TIME_SCALE
	return TIME_SCALE * (1 + (Singleton.cur_difficulty-1) * 0.4)

func get_spawn_scale():
	return (1 + (Singleton.cur_difficulty-1) * 0.6)

func wave(wave_name, duration, enemies):
	return WaveData.new(wave_name, duration, enemies)
