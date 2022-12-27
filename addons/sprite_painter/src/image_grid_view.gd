@tool
extends Node2D

@export var grid_color := Color.WHITE
@export var grid_line_width := 1.0

var image_size := Vector2i()
var grid_size := Vector2i()
var grid_offset := Vector2i()
var is_region := false


func _draw():
	if grid_size == Vector2i.ZERO: return
	if is_region:
		draw_polyline([
			grid_offset,
			grid_offset + Vector2i(grid_size.x, 0),
			grid_offset + grid_size,
			grid_offset + Vector2i(0, grid_size.y),
		], grid_color, grid_line_width)
		return

	var lines = []
	var line_count = Vector2i(
		float(image_size.x - grid_offset.x % grid_size.x) / grid_size.x,
		float(image_size.y - grid_offset.y % grid_size.y) / grid_size.y
	)
	lines.resize(line_count.x * 2)
	for i in line_count.x:
		lines[i * 2] = Vector2((i + 1) * grid_size.x + grid_offset.x, 0)
		lines[i * 2 + 1] = lines[i * 2] + Vector2(0, image_size.y)

	draw_multiline(lines, grid_color, grid_line_width)
	
	lines.resize(line_count.y * 2)
	for i in line_count.y:
		lines[i * 2] = Vector2(0, (i + 1) * grid_size.y + grid_offset.y)
		lines[i * 2 + 1] = lines[i * 2] + Vector2(image_size.x, 0)

	draw_multiline(lines, grid_color, grid_line_width)
