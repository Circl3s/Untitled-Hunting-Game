extends RigidBody

puppet var pup_transform = null
var revealed = true

func _ready():
	connect("body_entered", self, "_on_body_entered")
	pup_transform = transform
	collision_layer += 16
	contact_monitor = true
	contacts_reported = 10

func reveal():
	if revealed:
		return
	self.visible = true
	revealed = true

func _integrate_forces(_state):
	if is_network_master():
		rset("pup_transform", transform)
	else:
		transform = pup_transform

func _on_body_entered(node):
	if node.name == str(get_tree().get_network_unique_id()):
		print("Collision on %s" % name)
		rpc("_update", transform)

remote func _update(new_transform):
	print("Update prop: %s" % name)
	if revealed:
		revealed = false
		self.visible = false
		var old = StaticBody.new()
		old.set_name("%s_old" % name)
		for child in self.get_children():
			old.add_child(child.duplicate())
		old.set_script(preload("res://Scripts/OldProp.gd"))
		old.transform = transform
		owner.add_child(old)
