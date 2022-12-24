@tool
extends Control

signal pre_image_changed(image, rect_changed)
signal image_changed(image, rect_changed)
signal image_replaced(old_image, new_image)

@onready var image_view = $"%EditedImageView"
@onready var tool_manager = $"%ToolSwitcher"

var cur_scale := 1.0
var mouse_button := -1
var dragging := false
var edited_image : Image
var edited_image_path : String
var edited_image_selection : BitMap


func handle_input(event) -> bool:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT || event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				mouse_button = event.button_index
				return pass_event_to_tool(event)

			elif mouse_button == event.button_index:
				dragging = false
				mouse_button = -1
				var rect = tool_manager.get_affected_rect()
				pre_image_changed.emit(edited_image, rect)
				if pass_event_to_tool(event):
					image_changed.emit(edited_image, rect)
					return true
				
				else: return false

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			image_view.zoom(Vector2.ONE * 1.05)
			return true

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			image_view.zoom(Vector2.ONE / 1.05)
			return true

		if event.button_index == MOUSE_BUTTON_MIDDLE:
			return true

	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) || Input.is_key_pressed(KEY_SPACE):
			image_view.translate(event.relative)

		grab_focus()
		return pass_event_to_tool(event)

	if event is InputEventKey:
		return true

	return false


func pass_event_to_tool(event) -> bool:
	event.position = event.global_position - global_position
	return tool_manager.handle_image_input(
		image_view.event_vp_to_image(event),
		edited_image,
		edited_image_selection
	)


func edit_texture(tex_path : String):
	edited_image_path = tex_path
	edited_image = Image.load_from_file(tex_path)
	image_view.texture = ImageTexture.create_from_image(edited_image)
	image_view.call_deferred("update_position")


func resize_texture(old_image, old_size, new_size, expand_direction, stretch):
	if stretch:
		var new_image = Image.create(old_size.x, old_size.y, false, old_image.get_format())
		new_image.blit_rect(
			old_image,
			Rect2i(Vector2.ZERO, old_image.get_size()), Vector2i.ZERO
		)
		new_image.resize(new_size.x, new_size.y, Image.INTERPOLATE_NEAREST)
		return new_image

	else:
		var new_image = Image.create(new_size.x, new_size.y, false, old_image.get_format())
		var anchors = (Vector2i.ONE - expand_direction) / 2
		new_image.blit_rect(
			old_image,
			Rect2i(Vector2i.ZERO, old_image.get_size()),
			Vector2i(
				(new_size.x - old_size.x) * anchors.x,
				(new_size.y - old_size.y) * anchors.y,
			)
		)
		return new_image


func replace_image(old_image, new_image):
	edited_image = new_image


func _on_resize_value_changed(delta, expand_direction):
	var old_size = edited_image.get_size()

	var new_size = old_size + Vector2i(delta.round())
	var stretch =  Input.is_key_pressed(KEY_SHIFT)
	var new_image = resize_texture(edited_image, old_size, new_size, expand_direction, stretch)
	image_replaced.emit(edited_image, new_image)
	edited_image = new_image
