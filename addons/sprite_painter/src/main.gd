@tool
extends Control

@export var viewport_tex : NodePath

var editor_interface : EditorInterface
var editor_plugin : EditorPlugin
var edited_node : CanvasItem


func _ready():
	editor_interface.get_selection().selection_changed.connect(edit_selected_node)


func _on_visibility_changed():
	if is_visible_in_tree():
		edit_selected_node()


func edit_selected_node():
	if !is_visible_in_tree(): return
	if !try_fetch_first_editable_node():
		return

	var edited_node_was_visible = edited_node.visible
	edited_node.visible = false

	await RenderingServer.frame_post_draw

	get_node(viewport_tex).texture = editor_interface\
		.get_edited_scene_root()\
		.get_parent()\
		.get_texture()

	await RenderingServer.frame_post_draw
	get_node(viewport_tex).queue_redraw()
	edited_node.visible = edited_node_was_visible


#func _draw():
#	viewport_tex.draw_texture(viewport_tex.texture, Vector2.ZERO)


func try_fetch_first_editable_node():
	var selection = editor_interface.get_selection().get_selected_nodes()
	for x in selection:
		if "texture" in x:
			edited_node = x
			return true

	return false


func print_hierarchy(root : Node, indent : String = ""):
	for x in root.get_children():
		print(x.name.indent(indent) + " : " + x.get_class())
		print_hierarchy(x, indent + "-   ")
