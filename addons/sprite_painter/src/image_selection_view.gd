@tool
extends Control

@export var selection_color := Color(0.5, 0.5, 0.5, 0.5)

var selection : BitMap


func _ready():
	_on_visibility_changed()


func _process(delta):
	pass
#	if Engine.get_process_frames() % 10 != 0: return
#	self_modulate.a = abs(1.0 - Time.get_ticks_msec() * 0.0005)
#	if Engine.get_process_frames() % 120 != 0: return
#	if selection.get_true_bit_count() != selection.get_size().x * selection.get_size().y:
#	queue_redraw()


func _draw():
	var sel_size = selection.get_size()
	for i in sel_size.x:
		var draw_next = false
		var rect_height = 0
		for j in sel_size.y:
			if selection.get_bit(i, j) != draw_next && j != sel_size.y - 1:
				rect_height += 1

			elif rect_height > 0:
				draw_rect(Rect2(
					Vector2(i, j - rect_height),
					Vector2(1, rect_height)
				), selection_color)
				rect_height = 0

			draw_next = selection.get_bit(i, j)


func _on_visibility_changed():
	set_process(is_visible_in_tree())
