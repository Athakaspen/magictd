extends Sprite2D

var mana_amount : int
var speed : float # units per second
var destination_receiver : Object
var path_positions : Array[Vector2]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.position = path_positions.pop_front()
	tween_to_position(path_positions.pop_front())

func tween_to_position(new_pos : Vector2):
	var dist : float = position.distance_to(new_pos)
	var tween = create_tween()
	tween.tween_property(self, "position", new_pos, dist / speed)
	tween.tween_callback(end_tween)

func end_tween():
	if (!path_positions.is_empty()):
		print(path_positions)
		tween_to_position(path_positions.pop_front())
	else:
		destination_receiver.give_mana(mana_amount)
		print("given")
		self.queue_free()
