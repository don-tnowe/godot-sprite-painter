@tool
extends MarginContainer

signal color_changed(new_color, is_primary)

@export var workspace : NodePath
@export var picker_shortcut : Shortcut

@onready var color1_button = $Container/Box/Box/Box/Control/Color1
@onready var color2_button = $Container/Box/Box/Box/Control/Color2
@onready var palette = $Container/Box/Box/Palette
@onready var which_color_picked = $Container/Box/Box/WhichColor
@onready var color_picker_container = $Container/Box/Box2
@onready var color_picker = $Container/Box/Box2/ColorPicker
@onready var color_picker_tool_button = $Container/Box/Box/Box/Control/Control.get_child(0)

var color1 := Color("7f7f7f")
var color2 := Color("ffffff")

var color_picker_primary := true


func _ready():
	if get_viewport() is SubViewport: return

	size = Vector2.ZERO
	set_picked_primary(true, false)
	set_color(true, color1)
	set_color(false, color2)
	_on_visibility_changed()
	_yoink_color_picker_tool_button()


func set_color(is_primary, color):
	if is_primary:
		color1 = color
		color1_button.self_modulate = color

	else:
		color2 = color
		color2_button.self_modulate = color

	if color_picker_primary == is_primary:
		color_picker.color = color

	color_changed.emit(color, is_primary)


func set_picked_primary(is_primary, toggle_picker_shown = true):
	if toggle_picker_shown:
		color_picker_container.visible = !color_picker_container.visible

	color_picker_primary = is_primary
	color_picker.color = color1 if is_primary else color2
	if !color_picker_container.visible:
		which_color_picked.text = "Color"
	
	elif is_primary:
		which_color_picked.text = "Primary"

	else:
		which_color_picked.text = "Secondary"


func _input(event):
	if picker_shortcut.matches_event(event):
		# Only pick primary coor (for consistent feel if picker not open)
		set_picked_primary(true, false)
		color_picker_tool_button.button_pressed = !color_picker_tool_button.button_pressed
		return

	if event is InputEventKey:
		if event.keycode == KEY_CTRL:
			color_picker_tool_button.set_deferred("button_pressed", event.pressed)


func _yoink_color_picker_tool_button():
	for x in color_picker.get_child(1, true).get_children(true):
		if !x is Button:
			continue

		var old_button = color_picker_tool_button
		color_picker_tool_button = x
		x.get_parent().remove_child(x)
		x.toggled.connect(_on_picker_tool_toggled)
		x.shortcut = picker_shortcut
		x.shortcut_context = get_node(workspace)
		x.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		x.flat = true
		x.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		x.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		x.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
		old_button.replace_by(x)
		old_button.queue_free()
		break


func _on_color_picker_color_changed(color):
	set_color(color_picker_primary, color)


func _on_color_1_pressed():
	set_picked_primary(true, !color_picker_container.visible || color_picker_primary)


func _on_color_2_pressed():
	set_picked_primary(false, !color_picker_container.visible || !color_picker_primary)


func _on_swap_pressed():
	var swap = color1
	set_color(true, color2)
	set_color(false, swap)
	set_picked_primary(color_picker_primary, false)


func _on_picker_tool_toggled(button_pressed):
	# TODO
	pass


func _on_open_picker_toggled(button_pressed):
	color_picker_container.visible = button_pressed
	set_picked_primary(color_picker_primary)


func _on_palette_toggled(button_pressed):
	palette.visible = button_pressed


func _on_visibility_changed():
	set_process_input(visible)
