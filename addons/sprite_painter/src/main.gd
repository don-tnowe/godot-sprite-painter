@tool
extends Control

var editor_interface : EditorInterface
var editor_plugin : EditorPlugin
var editor_2d_vp : Control

var edited_node : CanvasItem


func edit_node(node : Node):
	pass


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
		x.owner = new_owner
		pack_to_owner(x, new_owner)


func _on_close_pressed():
	editor_plugin._on_enable_pressed()
