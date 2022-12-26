@tool
extends EditingTool

enum {
	SHAPE_RECTANGLE,
	SHAPE_ELLIPSE,
	SHAPE_TRIANGLE,
	SHAPE_DIAMOND,
	SHAPE_HEXAGON,
}

@export var crosshair_color := Color(0.5, 0.5, 0.5, 0.75)

var shape := 0
var fill_mode := 0
var border_width := 1
var replace := false
var aa := false

var drawing := false
var color_border : Color = Color.BLACK
var color_fill : Color = Color.WHITE
var image_size := Vector2()

var start_pos := Vector2i()
var end_pos := Vector2i()


func _ready():
	var icon_folder = "res://addons/sprite_painter/graphics/"
	add_name()
	start_property_grid()
	add_property("Shape", shape,
		func (x): shape = x,
		TOOL_PROP_ICON_ENUM,
		{
			load(icon_folder + "rect_shape_2d.svg") : "Rectangle",
			load(icon_folder + "circle_shape_2d.svg") : "Ellipse",
			load(icon_folder + "triangle_shape_2d.svg") : "Triangle",
			load(icon_folder + "diamond_shape_2d.svg") : "Diamond",
			load(icon_folder + "hex_shape_2d.svg") : "Hexagon",
		}
	)
	add_property("Fill Color", fill_mode,
		func (x): fill_mode = x,
		TOOL_PROP_ENUM,
		["Primary", "Secondary", "None (outline only)"]
	)
	add_property("Border Width", border_width,
		func (x): border_width = x,
		TOOL_PROP_INT,
		[0, 20]
	)
	add_property("Flags", [replace, aa],
		func (k, v):
			if k == 0: replace = v
			else: aa = v,
		TOOL_PROP_ICON_FLAGS,
		{"Eraser" : "Overwrite pixels under", "CurveTexture" : "Anti-Aliasing"}
	)


func mouse_pressed(
	event : InputEventMouseButton,
	image : Image,
	color1 : Color = Color.BLACK,
	color2 : Color = Color.WHITE,
	selection : BitMap = null,
):
	drawing = event.pressed
	color_border = color1
	color_fill = [color1, color2, Color.TRANSPARENT][fill_mode]
	image_size = image.get_size()
	if drawing:
		start_pos = Vector2i(event.position)
		end_pos = Vector2i(event.position)

	else:
		var rect = Rect2i(start_pos, Vector2i.ZERO).expand(end_pos).abs()
		if !replace:
			draw_shape(func(pos, sdf):
				set_image_pixel(
					image, pos.x, pos.y,
					image.get_pixelv(pos).blend(sdf_to_color(sdf))
				))

		else:
			draw_shape(set_image_pixel_from_sdf.bind(image))


func set_image_pixel_from_sdf(pos, sdf, image):
	if sdf >= 0.5:
		set_image_pixel(
			image, pos.x, pos.y,
			sdf_to_color(sdf)
		)

	elif sdf >= -0.5:
		set_image_pixel(
			image, pos.x, pos.y,
			lerp(
				image.get_pixelv(pos),
				sdf_to_color(sdf),
				min((sdf + 0.5) * 2, 1.0)
			)
		)


func get_affected_rect():
	var rect = Rect2i(start_pos, Vector2i.ZERO).expand(end_pos)
	if Input.is_key_pressed(KEY_SHIFT):
		rect.size = Vector2i.ONE * max(rect.size.x, rect.size.y)

	return rect


func mouse_moved(event : InputEventMouseMotion):
	if !drawing: return
	end_pos = event.position


func shape_sdf(pos : Vector2i, shape_size : Vector2i) -> float:
	shape_size -= Vector2i(1, 1)
	match shape:
		SHAPE_RECTANGLE:
			return minf(
				mini(pos.x, shape_size.x - pos.x),
				mini(pos.y, shape_size.y - pos.y)
			)

		SHAPE_ELLIPSE:
			# Stolen from:
			# https://iquilezles.org/articles/ellipsedist/
			var extents = shape_size * 0.5
			var posf = abs(Vector2(pos) - extents)

			var q = extents * (posf - extents)
			var cs = (Vector2(0.01, 1) if q.x < q.y else Vector2(1, 0.01)).normalized()
			for i in 3:
				var u = extents * Vector2(+cs.x, cs.y)
				var v = extents * Vector2(-cs.y, cs.x)
				var a = (posf - u).dot(v)
				var c = (posf - u).dot(u) + v.dot(v)
				var b = pow(c * c - a * a, 0.5)
				cs = Vector2(cs.x * b - cs.y * a, cs.y * b + cs.x * a) / c

			var d = (posf - extents * cs).length()
			return -d if (posf / extents).dot(posf / extents) > 1.0 else d

		SHAPE_TRIANGLE:
			var aspect = shape_size.aspect()
			var distance_to_diag = 0.0
			if (start_pos.x < end_pos.x) == (start_pos.y < end_pos.y):
				# Main diag
				if start_pos.x - end_pos.x < start_pos.y - end_pos.y:
					# Bottom filled
					distance_to_diag = (pos.x - pos.y * aspect)
				
				else:
					# Top filled
					# !!! incorrest sdf
					distance_to_diag = (pos.y * aspect - pos.x)

			else:
				# Secondary diag
				if start_pos.x - end_pos.x < end_pos.y - start_pos.y:
					# Bottom filled
					# !!! incorrest sdf
					distance_to_diag = (pos.y * aspect - shape_size.x + pos.x)

				else:
					# Top filled
					distance_to_diag = (shape_size.x - pos.x - pos.y * aspect)

			var rect_dist = minf(
				mini(pos.x, shape_size.x - pos.x),
				mini(pos.y, shape_size.y - pos.y)
			)
			return minf(distance_to_diag / aspect, rect_dist)

		SHAPE_DIAMOND:
			var from_center = (Vector2(pos) - shape_size * 0.5).abs()
			from_center.y *= shape_size.aspect()
			return shape_size.x * 0.5 - (from_center.x + from_center.y)

		SHAPE_HEXAGON:
			var inv_cos120 = 1.1547  # So all sides are equal.
			if start_pos.x - end_pos.x < start_pos.y - end_pos.y:
				pos = Vector2i(pos.y, pos.x)
				shape_size = Vector2i(shape_size.y, shape_size.x)

			if pos.x / shape_size.x < 0.5:
				pos.x = ceil(pos.x * inv_cos120)

			else:
				pos.x = floor(pos.x * inv_cos120)

			var diamond_from_center = (Vector2(pos) - shape_size * 0.5).abs() * Vector2(0.5, 1)
			diamond_from_center.y *= shape_size.aspect()
			var diamond_dist = shape_size.x * 0.5 - (diamond_from_center.x + diamond_from_center.y)
			var rect_dist = (shape_size.x * 0.5 - abs(pos.x - shape_size.x * 0.5)
			return minf(diamond_dist, (shape_size.x * 0.5 - abs(pos.x - shape_size.x * 0.5)))
		
		_:
			printerr("Invalid shape selected! (%s)" % shape)
			return -1.0


func draw_shape(call_each_pixel : Callable):
	var rect = get_affected_rect()
	for i in rect.size.x:
		for j in rect.size.y:
			call_each_pixel.call(
				rect.position + Vector2i(i, j),
				shape_sdf(Vector2i(i, j), rect.size)
			)


func sdf_to_color(sdf):
	# Debug
#	return Color(sdf * 0.1, -sdf * 0.1, 0.0, 1.0)
	if sdf < -0.5:
		return Color(color_border.r, color_border.g, color_border.b, 0)

	if sdf < 0 && aa && !replace:
		sdf = (sdf + 0.5) * 2
		return Color(color_border.r, color_border.g, color_border.b, sdf * sdf)

	if sdf <= border_width - 0.5:
		return color_border

	if sdf < border_width && aa:
		sdf = -(sdf - border_width + 0.5) * 2.0
		return lerp(color_fill, color_border, 1.0 - sdf * sdf)

	return color_fill


func draw_preview(image_view : CanvasItem, mouse_position : Vector2i):
	if drawing:
		# Function will operate on array: vars are bound to functions
		# and only the func's bound var is modified
		# Arrays, though, are passed by reference
		var draw_next = [Color.BLUE_VIOLET, 0]
		var cur_color : Color
		var rect = get_affected_rect()
		var start_at = min(rect.position.y, rect.end.y)
		var break_at = max(rect.position.y, rect.end.y)
		# Put a black BG behind: Replace mode is only useful
		# if used with transparency, so wouldn't be visible.
		var blend_color = Color.BLACK if replace else Color.TRANSPARENT
		draw_shape(func(pos, sdf):
			var rect_height = draw_next[1]
			var last_color = draw_next[0]
			cur_color = blend_color.blend(sdf_to_color(ceil(sdf)))
			if last_color != cur_color || pos.y == start_at:
				if rect_height >= 1 && last_color.a > 0.0:
					image_view.draw_rect(Rect2((
						Vector2i(pos.x, pos.y - rect_height)
						if pos.y != start_at else
						Vector2i(pos.x - 1, break_at - rect_height)
					), Vector2i(1, rect_height)), last_color)

				draw_next[1] = 0

			draw_next[1] += 1
			draw_next[0] = cur_color
		)

	else:
		image_view.draw_rect(Rect2i(mouse_position + Vector2i(0, 4), Vector2(1, 32)).abs(), crosshair_color)
		image_view.draw_rect(Rect2i(mouse_position - Vector2i(0, 3), Vector2(1, -32)).abs(), crosshair_color)
		image_view.draw_rect(Rect2i(mouse_position + Vector2i(4, 0), Vector2(32, 1)).abs(), crosshair_color)
		image_view.draw_rect(Rect2i(mouse_position - Vector2i(3, 0), Vector2(-32, 1)).abs(), crosshair_color)
