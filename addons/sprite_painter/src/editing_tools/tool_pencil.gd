@tool
extends EditingTool

var jaggies_removal := true


func _ready():
	add_name()
	start_property_grid()
	add_property("Jaggies Removal", jaggies_removal,
		func (x): jaggies_removal = x,
		TOOL_PROP_BOOL
	)
