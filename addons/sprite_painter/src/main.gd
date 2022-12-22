@tool
extends Control

@onready var workspace = $Box/Workspace
@onready var image_view = $"%EditedSprite"
@onready var border_rect = $"%BorderClip"

var editor_interface : EditorInterface
var editor_plugin : EditorPlugin
var editor_2d_vp : Control

var viewport_ignored := true
var local_camera_transform := Transform2D()
var edited_node : CanvasItem


func edit_node(node : Node = null):
	if node == null:
		if edited_node != null:
			edit_node(edited_node)

		return

	edited_node = node
	image_view.texture = node.texture
	mouse_filter = MOUSE_FILTER_STOP if viewport_ignored else MOUSE_FILTER_IGNORE
	update_position()


func _gui_input(event):
	handle_input(event)


func handle_input(event):
	var handled = false
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			local_camera_transform = local_camera_transform.scaled_local(Vector2.ONE * 1.05)
			
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			local_camera_transform = local_camera_transform.scaled_local(Vector2.ONE / 1.05)
			
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			handled = true

	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE) || Input.is_key_pressed(KEY_SPACE):
			local_camera_transform = local_camera_transform.translated(event.relative)
			handled = true
	
	update_position()
	return handled || workspace.handle_input(event)


func update_position():
	if !is_instance_valid(edited_node):
		return
	
	update_position_local()


func update_position_local():
	image_view.position = size * 0.5 + local_camera_transform.origin
	image_view.scale = local_camera_transform.get_scale()
	image_view.centered = true
	update_texture_view_rect()


func update_position_overlay():
	image_view.position = edited_node.global_position - edited_node.get_viewport().get_visible_rect().position
	image_view.centered = false
	image_view.scale = edited_node.global_scale if edited_node is Node2D else edited_node.scale
	apply_sprite_transforms(edited_node, image_view)
	# TODO: fetch source's actual on-screen position.
	update_texture_view_rect()


func apply_sprite_transforms(source, target : Sprite2D):
	if source is Sprite2D:
		target.offset = source.offset
		target.flip_h = source.flip_h
		target.flip_v = source.flip_v
		target.centered = source.centered
		
	else:
		target.offset = Vector2.ZERO
		target.flip_h = false
		target.flip_v = false
		target.centered = false


func update_texture_view_rect():
	border_rect.size = image_view.scale * image_view.texture.get_size()
	border_rect.position = image_view.position - Vector2(border_rect.patch_margin_left, border_rect.patch_margin_top)
	if image_view.centered:
		border_rect.position -= border_rect.size * 0.5
	
	border_rect.size += Vector2(
		border_rect.patch_margin_left + border_rect.patch_margin_right,
		border_rect.patch_margin_top + border_rect.patch_margin_bottom
	)


static func print_hierarchy(root : Node, indent : String = ""):
	for x in root.get_children():
		print(x.name.indent(indent) + " : " + x.get_class())
		print_hierarchy(x, indent + "-   ")


static func save_scene(root : Node):
	for x in root.get_children():
		pack_to_owner(root)

	var packed = PackedScene.new()
	packed.pack(root)
	packed.resource_path = "res://saved_scn.tscn"
	ResourceSaver.save(packed)


static func pack_to_owner(root : Node, new_owner : Node = root):
	for x in root.get_children():
		if root.filename != "":
			new_owner = root
		
		x.owner = new_owner
		pack_to_owner(x, new_owner)


func _on_close_pressed():
	editor_plugin._on_enable_pressed()
