

# Line3D
Line3D support for Godot Engine

# Features

This project aims to map 1:1 with the [Line2D](https://docs.godotengine.org/en/stable/classes/class_line2d.html) functionality in the engine. 
- **Point List** with 1:1 commands as the Line2D
	- add_point
	- remove_point
	- set_point_position
	- clear_points
	- get_point_count
	- get_point_position
- **Width** and **Width Curve** support
- **Texture** support
- **Texture Modes:** None, Tile, Stretch
- **Gradient** support

# Known Issues / Missing Features
- No line caps
- No line joins
- Might not be reliable if used dynamically

# How to Install

 1. Clone or download the zip from the repository
 2. Create an **addons** folder in your Godot Project
 3. Put the folder Line3D in the addons folder (its contents should be the files from the repo)
 4. Go in Project / Project Settings / Plugins
 5. Enable the plugin (if you don't see it, restart the engine)

# How to Use

After installing the plugin, you can create a new node called Line3D. It has similar features to Line2D.
In order for the Line3D to display correctly, you must have a Camera node in the scene.

# How to Contribute

 1. Follow the [gdscript style guide](https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/gdscript_styleguide.html)
 2. After you fix the issue or add a new feature, create a pull request
 3. Try to maintain a 1:1 compatibility with Line2D (when the same feature is present in both)

# Inspiration

[Line Renderer from dbp8890](https://github.com/dbp8890/line-renderer)
[Line3D from jegor377](https://github.com/jegor377/Line3D)
