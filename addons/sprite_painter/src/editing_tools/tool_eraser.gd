@tool
extends EditingTool

var brushsize := 5
var hardness := 1.0
var opacity := 1.0
var pen_flags := [true, false, false]


func _ready():
	add_name()
	start_property_grid()
	add_property("Size", brushsize,
		func (x): brushsize = x,
		TOOL_PROP_INT,
		[1, 256]
	)
	add_property("Hardness", hardness * 100,
		func (x): hardness = x * 0.01,
		TOOL_PROP_INT,
		[0, 100]
	)
	add_property("Strength", opacity * 100,
		func (x): opacity = x * 0.01,
		TOOL_PROP_INT,
		[0, 100]
	)
	add_property("Pen Pressure", pen_flags,
		func (k, v): pen_flags[k] = v,
		TOOL_PROP_ICON_FLAGS,
		{"ToolScale" : "Size", "Gradient" : "Opacity"}
	)
