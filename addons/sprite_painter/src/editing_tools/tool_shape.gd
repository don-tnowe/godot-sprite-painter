@tool
extends EditingTool

var shape := 0
var fill_mode := 0


func _ready():
	var icon_folder = "res://addons/sprite_painter/graphics/"
	add_name()
	start_property_grid()
	add_property("Shape", shape,
		func (x): shape = x,
		TOOL_PROP_ICON_ENUM,
		{
			load(icon_folder + "rect_shape_2d.svg") : "Rectangle",
			load(icon_folder + "circle_shape_2d.svg") : "Circle",
			load(icon_folder + "triangle_shape_2d.svg") : "Triangle",
			load(icon_folder + "diamond_shape_2d.svg") : "Diamond",
			load(icon_folder + "hex_shape_2d.svg") : "Hexagon",
		}
	)
	add_property("Fill Color", fill_mode,
		func (x): fill_mode = x,
		TOOL_PROP_ENUM,
		["Primary", "Secondary", "None (outline only)"]
	)
