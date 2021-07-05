tool
extends Path
class_name Line3D

export var curve_points:PoolVector3Array setget set_points, get_points
export var width : float = 0.1 setget set_width
export var width_curve : Curve setget set_width_curve

export var global_coords : bool = false setget set_global_coords
export(int, "None", "Tile", "Stretch") var texture_mode = 2 setget set_texture_mode
export var texture : Texture setget set_texture
export var default_color : Color = Color.white setget set_default_color
export var gradient : GradientTexture setget set_gradient
export var flat : bool = false setget set_flat
export var resolution : float = 1.0 setget set_resolution
export var cross_section_resolution : int = 10 setget set_cross_section_resolution
export var smooth : bool = false setget set_smooth

export var custom_material: Material setget set_material
export var follow_camera:=true setget set_follow_camera

var geometry = null
var geometry_script = preload("res://addons/Line3D/MeshInstance.gd")

func _enter_tree() -> void:
	reload_geometry()
	update()

func reload_geometry():
	for c in get_children():
		c.free()
	
	curve = Curve3D.new()
	
	geometry = MeshInstance.new()
	geometry.name = 'MeshInstance'
	geometry.set_script(geometry_script)
	geometry.connect('script_changed', self, 'update')
	add_child(geometry)

func _ready() -> void:
	connect('curve_changed', self, 'update')
	connect('script_changed', self, 'update')
	update()
	
func update():
	if geometry == null:
		call_deferred('reload_geometry')
	else:
		geometry.call_deferred('update')


func set_width(v):
	width = v
	update()
	
	
func set_width_curve(v):
	width_curve = v
	update()
	
	
func set_global_coords(v):
	global_coords = v
	update()
	
	
func set_texture_mode(v):
	texture_mode = v
	update()
	
	
func set_texture(v):
	texture = v
	update()
	
	
func set_default_color(v):
	default_color = v
	update()
	
	
func set_gradient(v):
	gradient = v
	update()
	
	
func set_flat(v):
	flat = v
	update()
	
	
func set_material(v):
	custom_material = v
	update()
	
	
func set_resolution(v):
	resolution = v
	update()
	
	
func set_cross_section_resolution(v):
	cross_section_resolution = v
	update()
	
	
func set_smooth(v):
	smooth = v
	update()
	
	
func set_follow_camera(v):
	follow_camera = v
	update()
	
	
func set_points(v):
	for i in range(v.size()):
		curve.set_point_position(i, v[i])
	update()
	
	
func get_points() -> PoolVector3Array:
	var ret = PoolVector3Array()
	for i in range(curve.get_point_count()):
		ret.append(curve.get_point_position(i))
	return ret
