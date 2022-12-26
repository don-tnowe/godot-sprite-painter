@tool
extends Control

signal tool_changed(tool_node)

@export var toolbar : NodePath
@export var toolbar_end : NodePath

var by_button := {}
var by_shortcut := {}

var current_tool : Control
var current_tool_shortcut_list := []
var current_color1 := Color.WHITE
var current_color2 := Color.WHITE


func _ready():
	if get_viewport() is SubViewport: return

	var end_at = get_node(toolbar_end)
	var default = null
	for x in get_node(toolbar).get_children():
		if x == end_at: break
		if !x is BaseButton: continue
		_setup_tool_button(x)
		if default == null && !x.disabled:
			default = x
	
	current_tool = default
	default.button_pressed = true
	default.show()


func _setup_tool_button(button : BaseButton):
	var tool_node = get_node_or_null(NodePath(button.name))
	by_button[button] = tool_node
	button.disabled = false
	if tool_node == null:
		button.disabled = true
		return

	if button.shortcut != null:
		var buttons_with_sc = by_shortcut.get(button.shortcut, [])
		buttons_with_sc.append(button)
		button.pressed.connect(button_shortcut_pressed.bind(
			button,
			buttons_with_sc
		))
		if buttons_with_sc.size() >= 2:
			button.set_deferred("shortcut", null)

		by_shortcut[button.shortcut] = buttons_with_sc

	button.tooltip_text = "%s (%s)" % [
		tool_node.tool_name,
		(button.shortcut.get_as_text() + " + ")\
			.repeat(by_shortcut[button.shortcut].size())\
			.trim_suffix(" + "),
	]
	tool_node.hide()
	button.toggled.connect(_on_tool_button_toggled.bind(tool_node))


func button_shortcut_pressed(button : BaseButton, list : Array):
	var pressed_in_list = list.find(button)
	if current_tool_shortcut_list != list:
		# Next time the shortcut is pressed, it will select the first from the list
		if current_tool_shortcut_list.size() > 1:
			var sc
			for x in current_tool_shortcut_list:
				if x.shortcut != null:
					sc = x.shortcut
					x.shortcut = null

			current_tool_shortcut_list[0].shortcut = sc

	list[(pressed_in_list + 1) % list.size()].shortcut = button.shortcut
	if list.size() > 1:
		button.shortcut = null

	current_tool_shortcut_list = list


func _on_tool_button_toggled(toggled : bool, tool_node : EditingTool):
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
		current_tool.selection = selection
		current_tool.mouse_pressed(
			event,
			image,
			current_color1 if event.button_index == MOUSE_BUTTON_LEFT else current_color2,
			current_color1 if event.button_index != MOUSE_BUTTON_LEFT else current_color2
		)
		return true

	return false


func get_affected_rect() -> Rect2i:
	return current_tool.get_affected_rect()


func draw_preview(image_view : CanvasItem, mouse_position : Vector2i):
	current_tool.draw_preview(image_view, mouse_position)


func draw_transparent_preview(image_view : CanvasItem, mouse_position : Vector2i):
	current_tool.draw_transparent_preview(image_view, mouse_position)


func _on_color_settings_color_changed(new_color, is_primary):
	if is_primary:
		current_color1 = new_color
		
	else:
		current_color2 = new_color
