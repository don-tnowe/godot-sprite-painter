@tool
extends Control

signal tool_changed(tool_node)

@export var toolbar : NodePath
@export var toolbar_end : NodePath

var current_tool : Control
var current_color1 := Color.WHITE
var current_color2 := Color.WHITE


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
			call_deferred("_on_tool_button_toggled", true, t)
			x.button_pressed = true

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


func handle_image_input(event, image, selection) -> bool:
	if current_tool == null: return false
	if event is InputEventMouseMotion:
		current_tool.mouse_moved(event)
		return true

	elif event is InputEventMouseButton:
		current_tool.mouse_pressed(
			event,
			image,
			current_color1 if event.button_index == MOUSE_BUTTON_LEFT else current_color2,
			current_color1 if event.button_index != MOUSE_BUTTON_LEFT else current_color2,
			selection
		)
		return true

	return false


func draw_preview(image_view : CanvasItem, mouse_position : Vector2i):
	current_tool.draw_preview(image_view, mouse_position)


func draw_transparent_preview(image_view : CanvasItem, mouse_position : Vector2i):
	current_tool.draw_transparent_preview(image_view, mouse_position)


func _on_color_settings_color_changed(new_color, is_primary):
	if is_primary:
		current_color1 = new_color
		
	else:
		current_color2 = new_color
