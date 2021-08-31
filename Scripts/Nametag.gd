extends Spatial

func _ready():
	var view = $Viewport
	$Viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var nmat = SpatialMaterial.new()
	nmat.flags_transparent = true
	nmat.albedo_texture = view.get_texture()
	self.material_override = nmat
