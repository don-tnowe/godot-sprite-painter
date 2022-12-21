@tool
extends EditorPlugin

var editor_view : Control
var undo_redo : EditorUndoRedoManager


func _enter_tree() -> void:
	editor_view = load(get_script().resource_path.get_base_dir() + "/src/main.tscn").instantiate()
	editor_view.editor_interface = get_editor_interface()
	editor_view.editor_plugin = self
	undo_redo = get_undo_redo()
	get_editor_interface().get_editor_main_screen().add_child(editor_view)
	_make_visible(false)


func _exit_tree() -> void:
	if is_instance_valid(editor_view):
		editor_view.queue_free()


func _get_plugin_name():
	return "Edit Sprite"
	

func _make_visible(visible):
	if is_instance_valid(editor_view):
		editor_view.visible = visible


func _edit(object):
	if editor_view.is_visible_in_tree():
		_make_visible(true)


func _has_main_screen():
	return true


func _get_plugin_icon():
	return get_editor_interface().get_base_control().get_theme_icon("CanvasItem", "EditorIcons")
