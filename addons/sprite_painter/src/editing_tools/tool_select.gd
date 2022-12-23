@tool
extends EditingTool

var mode := 0


func _ready():
	add_name()
	start_property_grid()
	add_property("Mode", mode,
		func (x): mode = x,
		TOOL_PROP_ENUM,
		["Replace", "Add", "Subtract", "Intersection", "XOr"]
	)
