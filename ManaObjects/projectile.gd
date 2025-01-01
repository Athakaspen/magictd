extends MeshInstance3D

var speed : float = 4.0
var target : Node3D
var damage : float
var start_position : Vector3

func setup(i_position : Vector3, i_target : Node3D, i_damage: float, i_speed: float = speed):
	start_position = i_position
	target = i_target
	damage = i_damage
	speed = i_speed

func _ready():
	self.global_position = start_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_instance_valid(target):
		# delete if target  is already dead
		self.queue_free()
	else:
		var vec_to = target.global_position - self.global_position
		if vec_to.length() < speed * delta * 2:
			do_hit()
		else:
			self.position += vec_to.normalized() * speed * delta

func do_hit():
	target.on_hit(damage)
	self.queue_free()
