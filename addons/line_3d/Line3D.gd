tool
extends ImmediateGeometry

export var points = [Vector3(0,0,0), Vector3(5,0,0)]
export var width : float = 1
export var width_curve : Curve

export var global_coords : bool = false
export(int, "None", "Tile", "Stretch") var texture_mode = 2
export var texture : Texture
export var color_mix_power : float = 0.5
export var default_color : Color = Color.white
export var gradient : GradientTexture

var camera : Camera
var camera_origin : Vector3

func _ready():
	material_override = preload("res://addons/line_3d/Line3D_material.tres")

func _process(delta):
	if gradient == null:
		material_override.set("shader_param/tint_power", color_mix_power)
		material_override.set("shader_param/gradient_power", 0)
	else:
		material_override.set("shader_param/tint_power", 0)
		material_override.set("shader_param/gradient_power", color_mix_power)
		
	if texture_mode == 0:
		material_override.set("shader_param/tint_power", 1)
	
	material_override.set("shader_param/albedo", default_color)
	material_override.set("shader_param/gradient", gradient)	
	material_override.set("shader_param/texture_albedo", texture)
	
	# Prevent render if not enough points
	if points.size() < 2:
		clear()
		return
		
	camera = get_viewport().get_camera()
	if camera == null:
		camera_origin = Vector3.UP	
	else:
		camera_origin = to_local(camera.get_global_transform().origin)
	
	var uv_progress_step : float = 1.0 / (points.size() - 1)
	var uv_progress : float = 0
	
	var progress_step : float = 1.0 / points.size()
	var progress : float = 0
	
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(points.size() - 1):
		var thickness_segment_start : float = width
		var thickness_segment_end : float = width
		var point_a : Vector3 = points[i]
		var point_b : Vector3 = points[i+1]
		
		if width_curve != null:
			thickness_segment_start = width_curve.interpolate(progress)
			thickness_segment_end = width_curve.interpolate(progress + progress_step)
		
		if global_coords:
			point_a = to_local(point_a)
			point_b = to_local(point_b)
	
		var point_ab : Vector3 = point_b - point_a
		var orth : Vector3 = (camera_origin - ((point_a + point_b) / 2)).cross(point_ab).normalized()
		var orthogonal_ab_start : Vector3 = orth * thickness_segment_start
		var orthogonal_ab_end : Vector3 = orth * thickness_segment_end
		
		var a_to_ab_start : Vector3 = point_a + orthogonal_ab_start
		var a_from_ab_start : Vector3 = point_a - orthogonal_ab_start
		var b_to_ab_end : Vector3 = point_b + orthogonal_ab_end
		var b_from_ab_end : Vector3 = point_b - orthogonal_ab_end

		match texture_mode:
			Line2D.LINE_TEXTURE_NONE:
				draw_stretch(a_to_ab_start, a_from_ab_start, b_to_ab_end, b_from_ab_end, 
							uv_progress, uv_progress_step)
			Line2D.LINE_TEXTURE_STRETCH:
				draw_stretch(a_to_ab_start, a_from_ab_start, b_to_ab_end, b_from_ab_end, 
							uv_progress, uv_progress_step)
			Line2D.LINE_TEXTURE_TILE:
				var ab_len = point_ab.length()
				var ab_floor = floor(ab_len)
				var ab_frac = ab_len - ab_floor
				
				set_uv(Vector2(ab_floor, 0))
				add_vertex(a_to_ab_start)
				set_uv(Vector2(-ab_frac, 0))
				add_vertex(b_to_ab_end)
				set_uv(Vector2(ab_floor, 1))
				add_vertex(a_from_ab_start)
				set_uv(Vector2(-ab_frac, 0))
				add_vertex(b_to_ab_end)
				set_uv(Vector2(-ab_frac, 1))
				add_vertex(b_from_ab_end)
				set_uv(Vector2(ab_floor, 1))
				add_vertex(a_from_ab_start)
		
		uv_progress += uv_progress_step
		progress += progress_step
		
	end()	
		
func draw_stretch(a_to_ab_start:Vector3, a_from_ab_start:Vector3, 
				b_to_ab_end:Vector3, b_from_ab_end:Vector3, 
				uv_progress:float, uv_progress_step:float):
	var zero = uv_progress
	var one = uv_progress + uv_progress_step 
	
	# Triangle 1
	set_uv(Vector2(zero, 0))
	add_vertex(a_to_ab_start)
	
	set_uv(Vector2(one, 0))
	add_vertex(b_to_ab_end)
	
	set_uv(Vector2(zero, 1))
	add_vertex(a_from_ab_start)
		
	# Triangle 2
	set_uv(Vector2(one, 0))
	add_vertex(b_to_ab_end)

	set_uv(Vector2(one, 1))
	add_vertex(b_from_ab_end)

	set_uv(Vector2(zero, 1))
	add_vertex(a_from_ab_start)

func add_point(position : Vector3, at_position : int = -1):
	if at_position == -1:
		points.append(position)
	else:
		points.insert(at_position, position)
		
func remove_point(i : int):
	if points.size() > i:
		points.remove(i)
		
func set_point_position(i : int, position : Vector3):
	if points.size() > i:
		points[i] = position
		
func clear_points():
	points.clear()		

func get_point_count():
	return points.size()
	
func get_point_position(i : int) -> Vector3:
	if points.size() > i:
		return points[i]
	return Vector3.ZERO
