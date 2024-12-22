extends Node2D

@export var mana_per_sec := 2

var is_mana_available := false
var wait_time := 1.0 / mana_per_sec

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	wait_time -= delta
	if(wait_time < 0):
		is_mana_available = true

func get_available_mana() -> int:
	if (is_mana_available): 
		return 1
	else:
		return 0

func take_mana(_amount):
	is_mana_available = false
	wait_time = 1.0 / mana_per_sec
