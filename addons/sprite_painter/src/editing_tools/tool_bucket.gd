@tool
extends EditingTool

var fill_mode := 0
var tolerance := 0.0

var drawing := false
var drawing_color := Color.BLACK
var image : Image
var start_color := Color.TRANSPARENT
var affected_pixels := BitMap.new()
var last_affected_rect := Rect2i()


func _ready():
	add_name()
	start_property_grid()
	add_property("Fill Mode", fill_mode,
		func (x): fill_mode = x,
		TOOL_PROP_ENUM,
		[&"Contiguous", &"Global"]
	)
	add_property("Tolerance", tolerance * 100,
		func (x): tolerance = x * 0.01,
		TOOL_PROP_INT,
		[0, 100]
	)


func mouse_pressed(
	event : InputEventMouseButton,
	image : Image,
	color1 : Color = Color.BLACK,
	color2 : Color = Color.WHITE,
	selection : BitMap = null,
):
	drawing = event.pressed
	drawing_color = Color.BLACK.blend(color1)
	start_color = image.get_pixelv(event.position)
	self.image = image
	if drawing:
		affected_pixels.create(image.get_size())
		start_fill(event.position)

	else:
		for i in image.get_width():
			for j in image.get_height():
				if affected_pixels.get_bit(i, j):
					image.set_pixel(i, j, color1)


func get_affected_rect():
	return last_affected_rect.grow_individual(0, 0, 1, 1)


func mouse_moved(event : InputEventMouseMotion):
	if !drawing: return
	if is_out_of_bounds(event.position): return

	var cur_color := image.get_pixelv(event.position)
	if cur_color == start_color:
		return
	
	start_color = cur_color
	start_fill(event.position)


func start_fill(pos : Vector2i):
	affected_pixels.create(image.get_size())
	last_affected_rect = Rect2i(pos, Vector2.ZERO)
	if (fill_mode == 0) != Input.is_key_pressed(KEY_SHIFT):
		floodfill(pos)

	else:
		mask_color(image.get_pixelv(pos))


func floodfill(start : Vector2i):
	var color := image.get_pixelv(start)

	var q = [start]
	while q.size() > 0:
		var x = q.pop_front()
		affected_pixels.set_bitv(x, true)
		add_if_fillable(x + Vector2i.RIGHT, q)
		add_if_fillable(x + Vector2i.DOWN, q)
		add_if_fillable(x + Vector2i.LEFT, q)
		add_if_fillable(x + Vector2i.UP, q)


func add_if_fillable(pos : Vector2i, to_array : Array = null):
	if is_out_of_bounds(pos) || affected_pixels.get_bitv(pos):
		return

	if get_color_distance_squared(start_color, image.get_pixelv(pos)) <= 4.0 * tolerance:
		last_affected_rect = last_affected_rect.expand(pos)
		affected_pixels.set_bitv(pos, true)
		if to_array != null:
			to_array.append(pos)


func mask_color(color):
	for i in image.get_width():
		for j in image.get_height():
			if get_color_distance_squared(start_color, image.get_pixel(i, j)) <= 4.0 * tolerance:
				last_affected_rect = last_affected_rect.expand(Vector2i(i, j))
				affected_pixels.set_bit(i, j, true)


func is_out_of_bounds(pos : Vector2i):
	return (
		pos.x < 0 || pos.y < 0
		|| pos.x >= image.get_width() || pos.y >= image.get_height()
	)


func get_color_distance_squared(a : Color, b : Color):
	return (
		(a.r - b.r) * (a.r - b.r)
		+ (a.g - b.g) * (a.g - b.g)
		+ (a.b - b.b) * (a.b - b.b)
		+ (a.a - b.a) * (a.a - b.a)
	)


func draw_preview(image_view : CanvasItem, mouse_position : Vector2i):
	if !drawing: return

	image_view.draw_rect(Rect2(mouse_position, Vector2.ONE), Color.WHITE)
	for i in image.get_width():
		var rect_height = 0
		for j in image.get_height():
			if affected_pixels.get_bit(i, j):
				rect_height += 1

			elif rect_height > 0:
				image_view.draw_rect(Rect2(
					Vector2(i, j - rect_height),
					Vector2(1, rect_height)
				), drawing_color)
				rect_height = 0
