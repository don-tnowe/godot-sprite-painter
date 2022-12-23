@tool
extends Control

@onready var workspace = $"%Workspace"

var editor_interface : EditorInterface
var editor_plugin : EditorPlugin
var editor_2d_vp : Control

var viewport_ignored := true
var edited_node : CanvasItem


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


func _on_workspace_image_changed():
	editor_interface.get_resource_filesystem().reimport_files([workspace.edited_image_path])
