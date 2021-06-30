tool
extends ImmediateGeometry

export var points = [Vector3(0,0,0), Vector3(5,0,0)]
export var width : float = 1
export var widthCurve : Curve

export var globalCoords : bool = false
export(int, "None", "Tile", "Stretch") var textureMode = 2
export var texture : Texture
export var tintColorPower : float = 0.5
export var tintColor : Color = Color.white
export var gradient : GradientTexture

var camera : Camera
var cameraOrigin : Vector3

func _ready():
	material_override = preload("res://addons/Line3D/Line3D_material.tres")

func _process(delta):
	if gradient == null:
		material_override.set("shader_param/tint_power", tintColorPower)
		material_override.set("shader_param/gradient_power", 0)
	else:
		material_override.set("shader_param/tint_power", 0)
		material_override.set("shader_param/gradient_power", tintColorPower)
		
	if textureMode == 0:
		material_override.set("shader_param/tint_power", 1)
	
	material_override.set("shader_param/albedo", tintColor)
	material_override.set("shader_param/gradient", gradient)	
	material_override.set("shader_param/texture_albedo", texture)
	
	# Prevent render if not enough points
	if points.size() < 2:
		clear()
		return
		
	camera = get_viewport().get_camera()
	if camera == null:
		cameraOrigin = Vector3.UP	
	else:
		cameraOrigin = to_local(camera.get_global_transform().origin)
	
	var uvProgressStep : float = 1.0 / (points.size() - 1)
	var uvProgress : float = 0
	
	var progressStep : float = 1.0 / points.size()
	var progress : float = 0
	
	clear()
	begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(points.size() - 1):
		var thicknessSegmentStart : float = width
		var thicknessSegmentEnd : float = width
		var pointA : Vector3 = points[i]
		var pointB : Vector3 = points[i+1]
		
		if widthCurve != null:
			thicknessSegmentStart = widthCurve.interpolate(progress)
			thicknessSegmentEnd = widthCurve.interpolate(progress + progressStep)
		
		if globalCoords:
			pointA = to_local(pointA)
			pointB = to_local(pointB)
	
		var pointAB : Vector3 = pointB - pointA
		var orth : Vector3 = (cameraOrigin - ((pointA + pointB) / 2)).cross(pointAB).normalized()
		var orthogonalABStart : Vector3 = orth * thicknessSegmentStart
		var orthogonalABEnd : Vector3 = orth * thicknessSegmentEnd
		
		var AtoABStart : Vector3 = pointA + orthogonalABStart
		var AfromABStart : Vector3 = pointA - orthogonalABStart
		var BtoABEnd : Vector3 = pointB + orthogonalABEnd
		var BfromABEnd : Vector3 = pointB - orthogonalABEnd

		match textureMode:
			Line2D.LINE_TEXTURE_NONE:
				draw_stretch(AtoABStart, AfromABStart, BtoABEnd, BfromABEnd, 
							uvProgress, uvProgressStep)
			Line2D.LINE_TEXTURE_STRETCH:
				draw_stretch(AtoABStart, AfromABStart, BtoABEnd, BfromABEnd, 
							uvProgress, uvProgressStep)
			Line2D.LINE_TEXTURE_TILE:
				var ABLen = pointAB.length()
				var ABFloor = floor(ABLen)
				var ABFrac = ABLen - ABFloor
				
				set_uv(Vector2(ABFloor, 0))
				add_vertex(AtoABStart)
				set_uv(Vector2(-ABFrac, 0))
				add_vertex(BtoABEnd)
				set_uv(Vector2(ABFloor, 1))
				add_vertex(AfromABStart)
				set_uv(Vector2(-ABFrac, 0))
				add_vertex(BtoABEnd)
				set_uv(Vector2(-ABFrac, 1))
				add_vertex(BfromABEnd)
				set_uv(Vector2(ABFloor, 1))
				add_vertex(AfromABStart)
		
		uvProgress += uvProgressStep
		progress += progressStep
		
	end()
	
	var psize = 3
	
	var p1 = 0
	var p2 = 1
	
	var uvProgressStep2 : float = 1.0 / (psize)
	var uvProgress2 : float = 0
	
		
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
	yield(get_tree(), "idle_frame")
		
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
