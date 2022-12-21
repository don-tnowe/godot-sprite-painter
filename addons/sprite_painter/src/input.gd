@tool
extends Control

@export var scale_min := 0.125
@export var scale_max := 8.0
@export var scale_step := 1.25

@export var viewport_tex : NodePath

var cur_scale := 1.0
var dragged := false


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			dragged = event.is_pressed()
		
		if dragged: return
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			pass
			
		if event.button_index == MOUSE_BUTTON_RIGHT:
			pass
			
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if cur_scale < scale_max:
				cur_scale /= scale_step
				
			get_node(viewport_tex).scale = max(cur_scale, scale_min) * Vector2.ONE
			
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if cur_scale < scale_max:
				cur_scale *= scale_step
				
			get_node(viewport_tex).scale = min(cur_scale, scale_max) * Vector2.ONE
	
	if event is InputEventMouseMotion:
		if dragged:
			get_node(viewport_tex).position -= event.relative * cur_scale
