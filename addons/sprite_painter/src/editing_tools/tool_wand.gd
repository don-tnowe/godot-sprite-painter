@tool
extends EditingTool

var fill_mode := 0
var tolerance := 0.0
var operation := 0.0


func _ready():
	add_name()
	start_property_grid()
	add_property("Fill Mode", fill_mode,
		func (x): fill_mode = x,
		TOOL_PROP_ENUM,
		[&"Contiguous", &"Global"]
	)
	add_property("Tolerance", tolerance * 100,
		func (x): tolerance = x * 0.01,
		TOOL_PROP_INT,
		[0, 100]
	)
	add_property("Operation", operation,
		func (x): operation = x,
		TOOL_PROP_ENUM,
		["Replace", "Add", "Subtract", "Intersection", "XOr"]
	)
