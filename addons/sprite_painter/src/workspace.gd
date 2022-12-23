@tool
extends Control

signal image_changed()

@onready var image_view = $"%EditedImageView"

var cur_scale := 1.0
var mouse_button := -1
var dragging := false
var edited_image : Image
var edited_image_path : String


func handle_input(event) -> bool:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT || event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				mouse_button = event.button_index
				return true

			elif mouse_button == event.button_index:
				dragging = false
				mouse_button = -1
				return true

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

		return true
	
	if event is InputEventKey:
		return true

	return false


func edit_texture(tex_path : String):
	edited_image_path = tex_path
	edited_image = Image.load_from_file(tex_path)
	image_view.texture = ImageTexture.create_from_image(edited_image)
	image_view.call_deferred("update_position")


func _on_resize_value_changed(delta, expand_direction):
	var old_size = edited_image.get_size()
	var new_size = old_size + Vector2i(delta.round())
	if Input.is_key_pressed(KEY_SHIFT):
		edited_image.resize(new_size.x, new_size.y, Image.INTERPOLATE_NEAREST)

	else:
		var new_image = Image.create(new_size.x, new_size.y, false, edited_image.get_format())
		var anchors = (Vector2i.ONE - expand_direction) / 2
		new_image.blit_rect(
			edited_image,
			Rect2i(Vector2.ZERO, edited_image.get_size()),
			Vector2i(
				(new_size.x - old_size.x) * anchors.x,
				(new_size.y - old_size.y) * anchors.y,
			)
		)
		
		edited_image.copy_from(new_image)
	
	var err = edited_image.save_png(edited_image_path)
	if err != OK: printerr(err)
	
	image_changed.emit()
	edit_texture(edited_image_path)
