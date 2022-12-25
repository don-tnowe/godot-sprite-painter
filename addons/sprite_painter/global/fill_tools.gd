@tool
class_name ImageFillTools


static func fill_on_image(
	image : Image,
	result_into_mask : BitMap,
	start_pos : Vector2i,
	tolerance : float = 0.0,
	fill_contiguous : bool = true
) -> Rect2i:
	var affected_rect : Rect2i
	result_into_mask.create(image.get_size())
	if fill_contiguous:
		affected_rect = flood_fill(image, result_into_mask, start_pos, tolerance)

	else:
		affected_rect = global_fill(image, result_into_mask, start_pos, tolerance)

	return affected_rect


static func flood_fill(
	image : Image,
	result_into_mask : BitMap,
	start_pos : Vector2i,
	tolerance : float = 0.0
) -> Rect2i:
	var start_color = image.get_pixelv(start_pos)
	var affected_rect = Rect2i(start_pos, Vector2.ZERO)
	var q = [start_pos]
	while q.size() > 0:
		var x = q.pop_front()
		result_into_mask.set_bitv(x, true)
		for pos in [x + Vector2i.RIGHT, x + Vector2i.DOWN, x + Vector2i.LEFT, x + Vector2i.UP]:
			if is_out_of_bounds(pos, image.get_size()) || result_into_mask.get_bitv(pos):
				continue

			if get_color_distance_squared(start_color, image.get_pixelv(pos)) <= tolerance:
				affected_rect = affected_rect.expand(pos)
				result_into_mask.set_bitv(pos, true)
				q.append(pos)

	return affected_rect


static func global_fill(
	image : Image,
	result_into_mask : BitMap,
	start_pos : Vector2i,
	tolerance : float = 0.0
) -> Rect2i:
	var start_color = image.get_pixelv(start_pos)
	var affected_rect = Rect2i(start_pos, Vector2.ZERO)
	for i in image.get_width():
		for j in image.get_height():
			if get_color_distance_squared(start_color, image.get_pixel(i, j)) <= tolerance:
				affected_rect = affected_rect.expand(Vector2i(i, j))
				result_into_mask.set_bit(i, j, true)

	return affected_rect


static func get_color_distance_squared(a : Color, b : Color) -> float:
	var a_sum = a.a + b.a
	return (
		(a.r - b.r) * (a.r - b.r)
		+ (a.g - b.g) * (a.g - b.g)
		+ (a.b - b.b) * (a.b - b.b)
	) * a_sum + (a.a - b.a) * (a.a - b.a) * (2.0 - a_sum)


static func is_out_of_bounds(pos : Vector2i, rect_size : Vector2i) -> bool:
	return (
		pos.x < 0 || pos.y < 0
		|| pos.x >= rect_size.x || pos.y >= rect_size.y
	)
