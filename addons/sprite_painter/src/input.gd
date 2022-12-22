@tool
extends Control

var cur_scale := 1.0
var mouse_button := -1
var dragging := false


func handle_input(event) -> bool:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT || event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				mouse_button = event.button_index

			elif mouse_button == event.button_index:
				dragging = false
				mouse_button = -1

		return true

	if event is InputEventMouseMotion && dragging:
		return true

	if event is InputEventKey:
		return true

	return false


func _on_visibility_changed():
	set_process_input(is_visible_in_tree())
