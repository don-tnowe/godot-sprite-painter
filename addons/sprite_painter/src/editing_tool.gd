@tool
class_name EditingTool
extends VBoxContainer

enum {
  TOOL_PROP_BOOL,
  TOOL_PROP_INT,
  TOOL_PROP_FLOAT,
  TOOL_PROP_ENUM,
  TOOL_PROP_ICON_ENUM,
  TOOL_PROP_ICON_FLAGS,
  TOOL_PROP_GRADIENT,
}

@export var tool_name := "Box Selection"

var _last_grid : GridContainer


func add_name():
	var label = Label.new()
	label.text = tool_name
	label.size_flags_vertical = SIZE_SHRINK_CENTER | SIZE_FILL
	add_child(label)
	
	var sep = ColorRect.new()
	sep.custom_minimum_size = Vector2(0, 2)
	sep.color = get_theme_color("accent_color", "Editor")
	sep.size_flags_horizontal = SIZE_EXPAND_FILL
	add_child(sep)

	_last_grid = null


func start_property_grid():
	var grid = GridContainer.new()
	grid.columns = 2
	_last_grid = grid
	add_child(grid)


func add_property(property_name, default_value, setter : Callable, type : int, hint = null):
	var parent = _last_grid
	if _last_grid == null:
		parent = HBoxContainer.new()
		add_child(parent)

	var label = Label.new()
	label.size_flags_vertical = SIZE_SHRINK_CENTER | SIZE_FILL
	label.text = property_name
	parent.add_child(label)

	var editor
	match type:
		TOOL_PROP_BOOL:
			editor = CheckBox.new()
			editor.button_pressed = default_value
			editor.text = "On"
			editor.toggled.connect(setter)

		TOOL_PROP_INT, TOOL_PROP_FLOAT:
			editor = EditorSpinSlider.new()
			if hint == null:
				editor.max_value = INF
				editor.min_value = -INF

			else:
				editor.min_value = hint[0]
				editor.max_value = hint[1]
				editor.hide_slider = false
			
			editor.value = default_value
			editor.step = 0.01 if type == TOOL_PROP_FLOAT else 1.0
			editor.custom_minimum_size.x = 64.0
			editor.value_changed.connect(setter)

		TOOL_PROP_ENUM:
			if hint.size() != 2:
				editor = OptionButton.new()
				for x in hint:
					editor.add_item(x)

				editor.item_selected.connect(setter)
				editor.select(default_value)

			else:
				editor = Button.new()
				editor.text = hint[default_value]
				editor.pressed.connect(func():
					var x = 1 if editor.text == hint[0] else 0
					editor.text = hint[x]
					setter.call(x)
				)

		TOOL_PROP_ICON_ENUM, TOOL_PROP_ICON_FLAGS:
			editor = HBoxContainer.new()
			var icons = hint if hint is Array else hint.keys()
			var tooltips = {} if hint is Array else hint
			var button

			var bgroup = ButtonGroup.new()

			for x in icons:
				button = ThemeIconButton.new()
				button.tooltip_text = tooltips.get(x)
				button.toggle_mode = true
				button.add_theme_stylebox_override("pressed", button.get_theme_stylebox("focus", "Button"))
				button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

				if x is Texture:
					button.set_deferred("icon", x)

				else:
					button._set_icon_name(x)

				editor.add_child(button)
				if type == TOOL_PROP_ICON_ENUM:
					button.button_group = bgroup
					button.toggled.connect(func(toggled):
						if !toggled: return
						setter.call(button.get_index())
					)
					button.button_pressed = default_value == button.get_index()

				else:
					button.toggled.connect(func(toggled):
						setter.call(button.get_index(), toggled)
					)
					button.button_pressed = default_value[button.get_index()]

		TOOL_PROP_GRADIENT:
			# TODO
			pass

	parent.add_child(editor)


func is_out_of_bounds(pos : Vector2i, rect_size : Vector2i):
	return (
		pos.x < 0 || pos.y < 0
		|| pos.x >= rect_size.x || pos.y >= rect_size.y
	)


func set_image_pixel(image : Image, x : int, y : int, color : Color):
	if !is_out_of_bounds(Vector2i(x, y), image.get_size()):
		image.set_pixel(x, y, color)


func mouse_pressed(
	event : InputEventMouseButton,
	image : Image,
	color1 : Color = Color.BLACK,
	color2 : Color = Color.WHITE,
	selection : BitMap = null,
):
	printerr("Not implemented: mouse_pressed! (" + get_script().resource_path.get_file() + ")")


func get_affected_rect() -> Rect2i:
	printerr("Not implemented: get_affected_rect! (" + get_script().resource_path.get_file() + ")")
	return Rect2i()


func mouse_moved(event : InputEventMouseMotion):
	printerr("Not implemented: mouse_moved! (" + get_script().resource_path.get_file() + ")")


func draw_preview(image_view : CanvasItem, mouse_position : Vector2i):
	printerr("Not implemented: draw_preview! (" + get_script().resource_path.get_file() + ")")


func draw_transparent_preview(image_view : CanvasItem, mouse_position : Vector2i):
	pass
