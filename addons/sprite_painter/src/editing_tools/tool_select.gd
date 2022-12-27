@tool
extends EditingTool

@export var preview_color := Color("1e90ff7f")

var operation := 0
var secondary_as_bg := false

var mouse_down := false
var selection_dragging := false
var image : Image
var draw_start := Vector2i()
var draw_end := Vector2i()
var image_size := Vector2i()


func _ready():
	add_name()
	start_property_grid()
	add_selection_common_properties()


func add_selection_common_properties():
	add_property("Operation", operation,
		func (x): operation = x,
		TOOL_PROP_ENUM,
		["Replace", "Add (Ctrl)", "Subtract (Right-click)", "Intersection", "Subtract Intersection"]
	)
	add_property("Background", 1 if secondary_as_bg else 0,
		func (x): secondary_as_bg = (x == 1),
		TOOL_PROP_ENUM,
		[&"Transparent", &"Secondary Color"]
	)


func mouse_pressed(
	event : InputEventMouseButton,
	image : Image,
	color1 : Color = Color.BLACK,
	color2 : Color = Color.WHITE,
):
	var subtract = Input.is_key_pressed(KEY_ALT) || event.button_index == MOUSE_BUTTON_RIGHT
	var add = Input.is_key_pressed(KEY_CTRL) || Input.is_key_pressed(KEY_META)
	self.image = image
	image_size = image.get_size()
	mouse_down = event.pressed
	if mouse_down:
		draw_start = event.position
		draw_end = draw_start
		selection_dragging = (
			!subtract && !add
			&& selection.get_bitv(event.position)
			&& !is_selection_empty()
		)

	elif selection_dragging:
		move_selected_pixels(
			image,
			Vector2i(draw_end - draw_start),
			add,
			color2 if secondary_as_bg else Color.TRANSPARENT
		)

	else:
		apply_selection(add, subtract)


func apply_selection(add_modifier, subtract_modifier):
	var rect = get_selection_rect()
	if operation == OPERATION_REPLACE || is_selection_empty():
		if !add_modifier && !subtract_modifier:
			selection.set_bit_rect(Rect2i(Vector2i.ZERO, image_size), false)

		selection.set_bit_rect(rect, !subtract_modifier)

	match operation:
		OPERATION_ADD:
			selection.set_bit_rect(rect, !subtract_modifier)

		OPERATION_SUBTRACT:
			selection.set_bit_rect(rect, subtract_modifier)

		OPERATION_INTERSECTION, OPERATION_XOR:
			var intersect = operation == OPERATION_INTERSECTION
			var result_bit
			for i in image_size.x:
				for j in image_size.y:
					result_bit = (
						selection.get_bit(i, j)
						&& rect.has_point(Vector2i(i, j))
					) if intersect else (
						selection.get_bit(i, j)
						!= rect.has_point(Vector2i(i, j))
					)
					selection.set_bit(i, j, result_bit != subtract_modifier)


func move_selected_pixels(image, drag_vec, copy, back_color):
	var old_sel = BitMap.new()
	old_sel.create(image_size)

	var old_pixels = []
	var source_selected := false
	old_pixels.resize(image_size.x * image_size.y)
	# Go through source pixels
	for i in image_size.x:
		for j in image_size.y:
			source_selected = selection.get_bit(i, j)
			old_sel.set_bit(i, j, source_selected)
			selection.set_bit(i, j, false)
			old_pixels[i + j * image_size.x] = image.get_pixel(i, j)
			if !copy && source_selected:
				image.set_pixel(i, j, back_color)

	# Paste into destination pixels
	var dest_pixel : Color
	var dest_pos : Vector2i
	for i in image_size.x:
		for j in image_size.y:
			dest_pos = Vector2i(i, j) - drag_vec
			if (is_out_of_bounds(dest_pos, image_size) || !old_sel.get_bitv(dest_pos)):
				continue

			selection.set_bit(i, j, true)
			dest_pixel = old_pixels[dest_pos.x + dest_pos.y * image_size.x]
			image.set_pixel(i, j, old_pixels[i + j * image_size.x].blend(dest_pixel))


func get_affected_rect():
	if selection_dragging:
		# Can be anything!
		return Rect2i(Vector2i.ZERO, image_size)

	else:
		return Rect2()


func get_selection_rect():
	if draw_start == draw_end: return Rect2i()
	return get_rect_from_drag(draw_start, draw_end, Input.is_key_pressed(KEY_SHIFT))


func mouse_moved(event : InputEventMouseMotion):
	draw_end = event.position


func draw_preview(image_view : CanvasItem, mouse_position : Vector2i):
	if mouse_down:
		if selection_dragging:
			ImageFillTools.draw_bitmap(
				image_view,
				selection,
				preview_color,
				mouse_position - draw_start
			)

		else:
			draw_selection_preview(image_view, mouse_position)

		return

	image_view.draw_rect(Rect2i(mouse_position + Vector2i(0, 4), Vector2(1, 32)).abs(), preview_color)
	image_view.draw_rect(Rect2i(mouse_position - Vector2i(0, 3), Vector2(1, -32)).abs(), preview_color)
	image_view.draw_rect(Rect2i(mouse_position + Vector2i(4, 0), Vector2(32, 1)).abs(), preview_color)
	image_view.draw_rect(Rect2i(mouse_position - Vector2i(3, 0), Vector2(-32, 1)).abs(), preview_color)


func draw_selection_preview(image_view : CanvasItem, mouse_position : Vector2i):
	image_view.draw_rect(get_selection_rect(), preview_color)
