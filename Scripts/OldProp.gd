extends PhysicsBody

func _ready():
	collision_layer = 16

func reveal():
	queue_free()
