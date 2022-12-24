@tool
class_name SpriteEditorRoot
extends Control

@onready var workspace = $"%Workspace"

var editor_interface : EditorInterface
var editor_plugin : EditorPlugin
var editor_2d_vp : Control

var viewport_ignored := true
var edited_node : CanvasItem
var undo_redo : EditorUndoRedoManager


func _ready():
#	var plugin_undoredo = editor_plugin.get_undo_redo()
#	var own_history_id = plugin_undoredo.get_object_history_id(self)
#	undo_redo = plugin_undoredo.get_history_undo_redo(own_history_id)
	undo_redo = editor_plugin.get_undo_redo()


func edit_node(node : Node = null):
	if node == null || node.texture == null || node.texture.resource_path == "":
		return

	edited_node = node
	mouse_filter = MOUSE_FILTER_STOP if viewport_ignored else MOUSE_FILTER_IGNORE
	workspace.call_deferred("edit_texture", node.texture.resource_path)


func _gui_input(event):
	handle_input(event)


func handle_input(event):
	return workspace.handle_input(event)


static func print_hierarchy(root : Node, indent : String = ""):
	for x in root.get_children(true):
		print(x.name.indent(indent) + " : " + x.get_class())
		print_hierarchy(x, indent + "-   ")


static func save_scene(root : Node):
	for x in root.get_children(true):
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


func _on_workspace_pre_image_changed(image : Image, rect):
	undo_redo.create_action("Edit image (start: %s, end: %s)" % [rect.position, rect.end])
	var saved_image = copy_image_rect(image, rect)
	undo_redo.add_undo_method(self, "paste_image_rect", saved_image, image, rect.position)
#	undo_redo.add_undo_method(func edit_undo():
#		paste_image_rect(saved_image, image, rect.position)
#	)


func _on_workspace_image_changed(image : Image, rect):
	var saved_image = copy_image_rect(image, rect)
	undo_redo.add_do_method(self, "paste_image_rect", saved_image, image, rect.position)
#	undo_redo.add_do_method(func edit_do():
#		paste_image_rect(saved_image, image, rect.position)
#	)
	undo_redo.commit_action()


func copy_image_rect(from, rect) -> Image:
	var new_image = Image.create(rect.size.x, rect.size.y, false, from.get_format())
	new_image.blit_rect(from, rect, Vector2.ZERO)
	return new_image


func paste_image_rect(from, to, destination = Vector2.ZERO):
	to.blit_rect(from, Rect2(Vector2.ZERO, from.get_size()), destination)
	save_changes(to)


func save_changes(image = null):
	if image == null:
		image = workspace.edited_image

	var err = image.save_png(workspace.edited_image_path)
	if err != OK: printerr(err)
	workspace.edit_texture(workspace.edited_image_path)


func _on_workspace_image_replaced(old_image, new_image):
	undo_redo.create_action("Resize image (%s -> %s)" % [old_image.get_size(), new_image.get_size()])
	undo_redo.add_undo_method(self, "save_changes",
		copy_image_rect(old_image, Rect2i(Vector2i.ZERO, old_image.get_size()))
	)
	undo_redo.add_do_method(self, "save_changes",
		copy_image_rect(new_image, Rect2i(Vector2i.ZERO, new_image.get_size()))
	)
#	undo_redo.add_undo_method(func edit_undo():
#		workspace.edited_image = copy_image_rect(
#			old_image,
#			Rect2i(Vector2i.ZERO, old_image.get_size())
#		)
#	)
#	undo_redo.add_do_method(func edit_do():
#		workspace.edited_image = copy_image_rect(
#			new_image,
#			Rect2i(Vector2i.ZERO, new_image.get_size())
#		)
#	)
	undo_redo.commit_action()
	var err = new_image.save_png(workspace.edited_image_path)
	if err != OK: printerr(err)
	workspace.edit_texture(workspace.edited_image_path)
