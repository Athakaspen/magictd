extends Node2D

@onready var mana_pos = $ManaPoint.global_position

@export var max_mana := 10
var cur_mana := 0

var max_link_range : float = 400.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Label.text = "Mana: " + str(cur_mana)

func get_requested_mana() -> int:
	return max_mana - cur_mana

func give_mana(amount : int):
	cur_mana += amount
