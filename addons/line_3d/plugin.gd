tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("Line3D", "ImmediateGeometry", preload("res://addons/line_3d/Line3D.gd"),
	preload("res://addons/line_3d/line_3d.png"))

func _exit_tree():
	remove_custom_type("Line3D")
