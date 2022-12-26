@tool
extends EditingTool

@export var preview_color := Color("1e90ff7f")

var selection_operations = [
	func(s, d): return s,
	func(s, d): return s || d,
	func(s, d): return s && !d,
	func(s, d): return s && d,
	func(s, d): return s || !d,
]

var mode := 0

var drawing := false
var draw_start := Vector2i()
var draw_end := Vector2i()
var image_size := Vector2()


func _ready():
	add_name()
	start_property_grid()
	add_property("Mode", mode,
		func (x): mode = x,
		TOOL_PROP_ENUM,
		["Replace", "Add", "Subtract", "Intersection", "Subtract Intersection"]
	)


func mouse_pressed(
	event : InputEventMouseButton,
	image : Image,
	color1 : Color = Color.BLACK,
	color2 : Color = Color.WHITE,
):
	drawing = event.pressed
	image_size = image.get_size()
	if drawing:
		draw_start = event.position
		draw_end = draw_start

	else:
		var rect = get_affected_rect()
		var op = selection_operations[mode]
		for i in image_size.x:
			for j in image_size.y:
				selection.set_bitv(
					Vector2i(i, j) + rect.position,
					op.call(
						selection.get_bit(i, j),
						rect.has_point(Vector2i(i, j))
					),
				)


func get_affected_rect():
	return Rect2i(draw_start, Vector2i.ZERO).expand(draw_end)


func mouse_moved(event : InputEventMouseMotion):
	draw_end = event.position


func draw_preview(image_view : CanvasItem, mouse_position : Vector2i):
	if drawing:
		image_view.draw_rect(get_affected_rect(), preview_color)
		return

	image_view.draw_rect(Rect2i(mouse_position + Vector2i(0, 4), Vector2(1, 32)).abs(), preview_color)
	image_view.draw_rect(Rect2i(mouse_position - Vector2i(0, 3), Vector2(1, -32)).abs(), preview_color)
	image_view.draw_rect(Rect2i(mouse_position + Vector2i(4, 0), Vector2(32, 1)).abs(), preview_color)
	image_view.draw_rect(Rect2i(mouse_position - Vector2i(3, 0), Vector2(-32, 1)).abs(), preview_color)
