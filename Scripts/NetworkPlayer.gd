extends RigidBody

const ray_len = 1000

puppet var pup_rotation = Vector3()
puppet var pup_translation = Vector3()

func _ready():
	var mat = SpatialMaterial.new()
	var id = int(name)
	if id == get_tree().get_network_unique_id():
		mat.albedo_color = Networking.current_player.color
		$Nametag/Viewport/Node2D/Label.text = Networking.current_player.username
	else:
		mat.albedo_color = Networking.player_info[id].color
		$Nametag/Viewport/Node2D/Label.text = Networking.player_info[id].username
	$Model/MeshInstance.set_surface_material(0, mat)
	var view = $Nametag/Viewport
	$Nametag/Viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var nmat = SpatialMaterial.new()
	nmat.flags_transparent = true
	nmat.albedo_texture = view.get_texture()
	$Nametag.material_override = nmat

func _physics_process(_delta):
	if is_network_master():
		var mouse = get_viewport().get_mouse_position()
		var from = $Camera.project_ray_origin(mouse)
		var to = from + $Camera.project_ray_normal(mouse) * ray_len
		var res = get_world().direct_space_state.intersect_ray(from, to, [self], 2)
		if res:
			var model_transform = $Model.get_global_transform()
			var target = Vector3(res.position.x, model_transform.origin.y, res.position.z)
			$Model.look_at(target, Vector3.UP)
			rset("pup_rotation", $Model.rotation)
		rset("pup_translation", translation)
		var overlapping = $Model/Area.get_overlapping_bodies()
		if overlapping.size() > 0:
			for body in overlapping:
				if body.has_method("reveal"):
					body.reveal()
	else:
		$Model.rotation = pup_rotation
		translation = pup_translation

func _integrate_forces(state):
	if is_network_master():
		if Input.is_action_pressed("ui_up"):
			var model = $Model.get_transform().basis
			state.add_central_force(-model.z*25)
