extends RigidBody

remotesync var pup_transform = null
var last_transform = null
var revealed = false

func _ready():
	pup_transform = transform
	last_transform = transform
	collision_layer += 16
	visible = false
	spawn_static_copy()

func reveal():
	if revealed:
		return
	visible = true
	revealed = true

func hide():
	if not revealed:
		return
	visible = false
	revealed = false
	spawn_static_copy()

func spawn_static_copy():
	var old = StaticBody.new()
	old.collision_layer = 16
	old.collision_mask = 16
	old.set_name("%s_old" % name)
	for child in self.get_children():
		old.add_child(child.duplicate())
	old.set_script(preload("res://Scripts/OldProp.gd"))
	old.transform = transform
	owner.call_deferred("add_child", old)

func _physics_process(_delta):
	if mode == RigidBody.MODE_STATIC:
		return
	if last_transform != transform:
		rset("pup_transform", transform)
	elif pup_transform != transform:
		transform = pup_transform
	last_transform = transform
