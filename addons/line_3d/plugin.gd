tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("Line3D", "Path", preload("res://addons/line_3d/Line3D.gd"),
	preload("res://addons/line_3d/Line3D-gd3.svg"))

func _exit_tree():
	remove_custom_type("Line3D")
