extends ManaObject
class_name ManaRelay

# position that mana packets should pass through
@onready var mana_transit_pos : Vector3 = $ManaPoint.global_position

@export var cost : int = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func on_hit(_damage):
	Singleton.network_manager.remove_mana_object(self)
	self.queue_free()
