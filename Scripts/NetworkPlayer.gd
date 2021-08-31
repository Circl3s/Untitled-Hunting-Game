extends RigidBody

const ray_len = 1000

puppet var pup_rotation = Vector3()
puppet var pup_translation = Vector3()

var mat = SpatialMaterial.new()
var seen = true
var revealed = []

func _ready():
	$Model/MeshInstance.set_surface_material(0, mat)

func set_color(color):
	mat.albedo_color = color

func set_username(name):
	$Nametag/Viewport/Node2D/Label.text = name

func reveal():
	change_visibility(true)

func hide():
	change_visibility(false)

func change_visibility(visibility):
	if seen == visibility:
		return
	seen = visibility
	visible = visibility

func _process(_delta):
	Debug.DrawCircle(Vector3(0, 1.1, 0), 20)

func _physics_process(_delta):
	if is_network_master():
		var mouse = get_viewport().get_mouse_position()
		var from = $Camera.project_ray_origin(mouse)
		var to = from + $Camera.project_ray_normal(mouse) * ray_len
		var res = get_world().direct_space_state.intersect_ray(from, to, [self], 2)
		if res:
			var model_transform = $Model.get_global_transform()
			var target = Vector3(res.position.x, model_transform.origin.y, res.position.z)
			Debug.DrawLine(model_transform.origin, res.position)
			$Model.look_at(target, Vector3.UP)
			rset("pup_rotation", $Model.rotation)
		rset("pup_translation", translation)
		var overlapping = $Model/Area.get_overlapping_bodies()
		for body in revealed:
			if body in overlapping:
				continue
			if is_instance_valid(body):
				body.hide()
			revealed.erase(body)
		for body in overlapping:
			if body.has_method("reveal"):
				body.reveal()
				if not body in revealed:
					revealed.append(body)
	else:
		$Model.rotation = pup_rotation
		translation = pup_translation

func _integrate_forces(state):
	if is_network_master():
		var model = $Model.get_transform().basis
		if Input.is_action_pressed("ui_up"):
			state.add_central_force(-model.z*25)
		if Input.is_action_pressed("ui_down"):
			state.add_central_force(model.z*25)
