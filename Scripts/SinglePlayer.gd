extends RigidBody

const ray_len = 1000

func _ready():
	var view = $Nametag/Viewport
	$Nametag/Viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	$Nametag.material_override.albedo_texture = view.get_texture()

func _physics_process(_delta):
	var mouse = get_viewport().get_mouse_position()
	var from = $Camera.project_ray_origin(mouse)
	var to = from + $Camera.project_ray_normal(mouse) * ray_len
	var res = get_world().direct_space_state.intersect_ray(from, to, [self], 2)
	if res:
		var model_transform = $Model.get_global_transform()
		var target = Vector3(res.position.x, model_transform.origin.y, res.position.z)
		$Model.look_at(target, Vector3.UP)
	var overlapping = $Model/Area.get_overlapping_bodies()
	if overlapping.size() > 0:
		for body in overlapping:
			if body.has_method("reveal"):
				body.reveal()

func _integrate_forces(state):
	if Input.is_action_pressed("ui_up"):
		var model = $Model.get_transform().basis
		state.add_central_force(-model.z*25)
