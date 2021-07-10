tool
extends MeshInstance

export var uv_scale: Vector2 = Vector2(4.0,1.0)

onready var line3D = get_parent()
var camera

var custom_line_material = preload("res://addons/line_3d/Line3D_spatial_material.tres")

func _ready():
	update()

func update():
	if line3D == null:
		line3D = get_parent()

	if camera == null:
		camera = get_viewport().get_camera()		
		
	update_shader()
	draw()
#	print('DRAW')


func update_shader():
	if line3D.custom_material != null:
		material_override = line3D.custom_material
	else:
		material_override = custom_line_material.duplicate()
		material_override.set('albedo_texture', line3D.texture)
	

func draw():
	var _cross_section = _generate_crossection()
	var cross_section: Curve3D = _cross_section.curve
	var path: Path = line3D	# following these
	var curve: Curve3D = path.curve
	var step_size: float = 1.0 / line3D.resolution 	# at this interval
	var smooth: bool = line3D.smooth
	#var close_caps: bool = get_input_single(6, false)

	if step_size == 0:
		step_size = 0.01

#	if not cross_section or not curve or curve.get_point_count() == 0:
#		return

	var surface_tool := SurfaceTool.new()

	surface_tool.clear()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.add_smooth_group(smooth)

	var length: float = curve.get_baked_length()
	var steps: int = floor(length / step_size)
	if steps == 0:
		return

	var offset: float = length / steps
	var count: int = cross_section.get_point_count()
	var up = Vector3(1, 0, 0)

	var camera_pos = null
	if camera:
		camera_pos = to_local(camera.global_transform.origin)
		
	for i in range(steps + 1):
		var current_offset: float = i * offset
		var position_on_curve: Vector3 = curve.interpolate_baked(current_offset)

		var position_2: Vector3
		if current_offset + 0.1 < length:
			position_2 = curve.interpolate_baked(current_offset + 0.1)
		else:
			position_2 = curve.interpolate_baked(current_offset - 0.1)
			position_2 += (position_on_curve - position_2) * 2.0

		var taper_size = line3D.width
		if line3D.width_curve:
			taper_size = line3D.width_curve.interpolate_baked(float(i) / float(steps))
		var node = Spatial.new()

		if camera and line3D.flat_direction == 0:
			var cam_dir = (camera_pos - position_on_curve).normalized()
			node.look_at_from_position(position_on_curve, position_2, Vector3.UP)
			node.rotate_object_local(Vector3(0,0,1), Vector3.UP.angle_to(cam_dir))
		else:
			node.look_at_from_position(position_on_curve, position_2, line3D.custom_flat_direction)
		up = node.transform.basis.y
		
		for j in range(count):
			var pos = taper_size * cross_section.get_point_position(j)
			pos = node.transform.xform(pos)

			# TODO : Adding UV breaks the smooth group
			if line3D.gradient != null:
				surface_tool.add_color(line3D.gradient.gradient.interpolate(current_offset / length))
			elif line3D.default_color:
				surface_tool.add_color(line3D.default_color)
			else:
				surface_tool.add_color(Color(1, 1, 1, 1))
			
			var wrap = 1
			if line3D.flat:
				wrap = 2
			match line3D.texture_mode:
				Line2D.LINE_TEXTURE_NONE:
					surface_tool.add_uv(Vector2(
						current_offset / length * uv_scale.x, 
						j / float(count-1) * uv_scale.y * wrap))
				Line2D.LINE_TEXTURE_STRETCH:
					surface_tool.add_uv(Vector2(
						current_offset / length * 1.0, 
						j / float(count-1) * 1.0 * wrap))
				Line2D.LINE_TEXTURE_TILE:
					if line3D.texture != null:
						var taper_wrap = PI
						if line3D.flat:
							taper_wrap = 2
						surface_tool.add_uv(Vector2(
							current_offset / taper_size / taper_wrap, 
							j / float(count-1) * 1 * wrap))
					else:
						surface_tool.add_uv(Vector2(
							current_offset / length * 1, 
							j / float(count-1) * 1 * wrap))
				3:
					if line3D.texture != null:
						var taper_wrap = PI
						if line3D.flat:
							taper_wrap = 2
						surface_tool.add_uv(Vector2(
							current_offset / taper_size / taper_wrap, 
							j / float(count-1) * 1 * wrap * 2))
					else:
						surface_tool.add_uv(Vector2(
							current_offset / length * 1, 
							j / float(count-1) * 1 * wrap * 2))
			if line3D.global_coords:
				pos = to_local(pos)
			else:
				pos -= transform.origin
			surface_tool.add_vertex(pos)

		if i > 0:
			for k in range(count - 1):
				surface_tool.add_index((i - 1) * count + k)
				surface_tool.add_index((i - 1) * count + k + 1)
				surface_tool.add_index(i * count + k)

				surface_tool.add_index(i * count + k)
				surface_tool.add_index((i - 1) * count + k + 1)
				surface_tool.add_index(i * count + k + 1)

	surface_tool.generate_normals()

	transform = path.transform
	mesh = surface_tool.commit()


func _generate_crossection(
	radius := 1.0, 
	axis:=Vector3.UP, 
	origin:=Vector3.ZERO
	) -> Path:
		
	var count = line3D.cross_section_resolution
	var flat = line3D.flat
	var angle_offset := 0
	var _angle_offset: float = angle_offset + (2 * PI) / count

	var t = Transform()
	if axis != Vector3.ZERO:
		t = t.looking_at(axis.normalized(), Vector3(0, 0, 1))

	var curve = Curve3D.new()

	if flat:
		curve.add_point(Vector3(1,0,0))
		curve.add_point(Vector3(-1,0,0))
		curve.add_point(Vector3(1,0,0))
	else:
		for i in range(count+2, 0, -1):
			var v = Vector3.ZERO
			v.x = cos(_angle_offset * i)
			v.z = sin(_angle_offset * i)
			v *= radius
			v = t.xform(v)
			curve.add_point(v)

	var path = Path.new()
	path.curve = curve
	path.translation = origin

	return path
