extends ImmediateGeometry

class DebugGeometry:
	var time
	
	func _init(duration = 0):
		self.time = duration
	
	func draw(_node):
		pass

class Point:
	extends DebugGeometry
	const primitive = Mesh.PRIMITIVE_POINTS
	var position
	
	func _init(pos, duration = 0):
		._init(duration)
		self.position = pos
	
	func draw(node):
		node.add_vertex(position)

class Line:
	extends DebugGeometry
	const primitive = Mesh.PRIMITIVE_LINES
	var start
	var end
	
	func _init(start_point, end_point, duration = 0):
		._init(duration)
		self.start = start_point
		self.end = end_point
	
	func draw(node):
		node.add_vertex(start)
		node.add_vertex(end)

class Circle:
	extends DebugGeometry
	const primitive = Mesh.PRIMITIVE_LINE_LOOP
	var center
	var radius
	var points
	
	func _init(center_point, circle_radius, circle_points = 100, duration = 0):
		._init(duration)
		assert(circle_points > 1, "ERROR: A circle can't have less than 2 points")
		assert(circle_radius > 0, "ERROR: Radius of a circle can't be 0 or lower")
		self.center = center_point
		self.radius = circle_radius
		self.points = circle_points
	
	func draw(node):
		var step = (2*PI) / points
		for i in range(points):
			var x = center.x + cos(i*step) * radius
			var z = center.z + sin(i*step) * radius
			node.add_vertex(Vector3(x, center.y, z))

class Poly2D:
	extends DebugGeometry
	const primitive = Mesh.PRIMITIVE_LINE_LOOP
	var y
	var list
	
	func _init(y_plane, point_list, duration = 0):
		._init(duration)
		assert(point_list is Array)
		assert(point_list.size() > 1)
		assert(point_list[0] is Vector2)
		self.y = y_plane
		self.list = point_list
	
	func draw(node):
		for vec in list:
			node.add_vertex(Vector3(vec.x, y, vec.y))

var debug_geometry = []
var mat = SpatialMaterial.new()

func _ready():
	self.set_cast_shadows_setting(0)
	mat.set_line_width(3)
	mat.set_point_size(3)
	mat.set_flag(SpatialMaterial.FLAG_UNSHADED, true)
	mat.set_flag(SpatialMaterial.FLAG_USE_POINT_SIZE, true)
	mat.set_albedo(Color.red)
	set_material_override(mat)

func _process(delta):
	clear()
	for goemtry in debug_geometry:
		begin(goemtry.primitive, null)
		goemtry.draw(self)
		end()
		goemtry.time -= delta
		if goemtry.time <= 0:
			debug_geometry.erase(goemtry)

func set_color(color):
	mat.set_albedo(color)

func DrawLine(start, end, duration = 0):
	debug_geometry.append(Line.new(start, end, duration))

func DrawPoint(point, duration = 0):
	debug_geometry.append(Point.new(point, duration))

func DrawCircle(center, radius, points = 100, duration = 0):
	debug_geometry.append(Circle.new(center, radius, points, duration))

func DrawPoly2D(y_plane, point_list, duration = 0):
	debug_geometry.append(Poly2D.new(y_plane, point_list, duration))
