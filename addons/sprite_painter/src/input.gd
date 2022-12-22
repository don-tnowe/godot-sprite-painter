@tool
extends Control

var cur_scale := 1.0
var dragging := false


func _input(event):
	if event is InputEventMouse:
		if !get_global_rect().has_point(event.position):
			return

		if event is InputEventMouseMotion:
			if dragging:
				accept_event()

			return 

		if event.button_index == MOUSE_BUTTON_LEFT || event.button_index == MOUSE_BUTTON_RIGHT:
			accept_event()
			dragging = event.pressed
			return


func _gui_input(event):
	return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			accept_event()
			
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			accept_event()
		
		else:
			event.position += global_position
			mouse_filter = MOUSE_FILTER_IGNORE
			get_viewport().push_input(event)
			await get_tree().process_frame
			mouse_filter = MOUSE_FILTER_PASS
	
	if event is InputEventMouseMotion:
		event.position += global_position
		mouse_filter = MOUSE_FILTER_IGNORE
		get_viewport().push_input(event)
		await get_tree().process_frame
		mouse_filter = MOUSE_FILTER_PASS


func _on_visibility_changed():
	set_process_input(is_visible_in_tree())
