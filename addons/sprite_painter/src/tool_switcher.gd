@tool
extends Control

signal tool_changed(tool_node)

@export var toolbar : NodePath
@export var toolbar_end : NodePath

var current_tool : Control


func _ready():
	var end_at = get_node(toolbar_end)
	var default = null
	for x in get_node(toolbar).get_children():
		if x == end_at: break
		if !x is BaseButton: continue

		var t = get_node_or_null(NodePath(x.name))
		if t == null:
			x.disabled = true
			continue

		if default == null:
			default = x
			x.set_deferred("button_pressed", true)

		t.hide()
		x.tooltip_text = t.tool_name
		x.toggled.connect(_on_tool_button_toggled.bind(t))


func _on_tool_button_toggled(toggled, tool_node):
	if !toggled: return

	if current_tool != null:
		current_tool.hide()

	tool_node.show()
	current_tool = tool_node
	tool_changed.emit(tool_node)
