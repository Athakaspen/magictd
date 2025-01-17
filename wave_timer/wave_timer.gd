extends Control
class_name WaveTimer

@onready var slider = $Slider
@onready var slider_init_pos = slider.position

const block_res = preload("res://wave_timer/timeline_block.tscn")
const label_res = preload("res://wave_timer/wave_label.tscn")

const TIME_SCALE = 64 # px per sec

func _ready():
	for n in slider.get_children():
		n.queue_free()
	init_blocks(%WaveManager.waves_dict)

func init_blocks(waves_dict : Dictionary):
	var blocks_left = 0
	var i = 0
	while(i <= waves_dict.keys().max() or blocks_left > 0):
		var maybe_data = waves_dict.get(i)
		if maybe_data != null:
			blocks_left = maybe_data.duration
			var label = label_res.instantiate()
			label.text = maybe_data.name
			label.position += Vector2.RIGHT * i * TIME_SCALE
			slider.add_child(label)
		var block = block_res.instantiate()
		block.position += Vector2.RIGHT * i * TIME_SCALE
		block.visible = blocks_left > 0
		blocks_left -= 1
		slider.add_child(block)
		i += 1

func update_timer(time: float):
	$Slider.position = slider_init_pos + Vector2.LEFT * time * TIME_SCALE
