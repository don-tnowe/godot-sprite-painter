@tool
extends EditorPlugin

var editor_view : Control
var editor_2d_vp : Control
var enable_button : Button
var sploinky := Control.new()
var undo_redo : EditorUndoRedoManager

var overlay_enabled := false


func _enter_tree() -> void:
	var ui := get_editor_interface()

	editor_view = load(get_script().resource_path.get_base_dir() + "/src/main.tscn").instantiate()
	editor_view.editor_interface = ui
	editor_view.editor_plugin = self
	undo_redo = get_undo_redo()

	_connect_2d_editor()
	_connect_enable_button()

	main_screen_changed.connect(_on_main_screen_changed)
	ui.get_selection().selection_changed.connect(_on_selection_changed)

	ui.get_base_control().add_child(editor_view)
	_on_editor_resized()

	make_visible(false)


func _connect_2d_editor():
	for x in get_editor_interface().get_editor_main_screen().get_children():
		if x.get_class() == "CanvasItemEditor":
			editor_2d_vp = x
			editor_view.editor_2d_vp = x
			break
	
	editor_2d_vp.resized.connect(_on_editor_resized)
	editor_2d_vp.add_child(sploinky)
	editor_2d_vp.move_child(sploinky, 1)


func _connect_enable_button():
	enable_button = Button.new()
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, enable_button)
	
	enable_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	enable_button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	enable_button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	enable_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	enable_button.icon = enable_button.get_theme_icon("StyleBoxTexture", "EditorIcons")
	enable_button.text = "Edit Texture..."
	enable_button.pressed.connect(_on_enable_pressed)
	enable_button.hide()


func _exit_tree() -> void:
	if is_instance_valid(editor_view):
		editor_view.queue_free()
		sploinky.queue_free()
		enable_button.queue_free()


func make_visible(visible):
	if is_instance_valid(editor_view):
		editor_view.visible = visible
		editor_2d_vp.get_child(0).visible = !visible
		sploinky.custom_minimum_size.y = editor_2d_vp.get_child(0).size.y
		sploinky.visible = visible
		add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM, Button.new())


func _edit(object):
	if overlay_enabled:
		make_visible(true)
		editor_view.edit_node(object)


func _handles(object):
	if !object is Node:
		return false

	return "texture" in object


func _on_enable_pressed():
	overlay_enabled = !overlay_enabled
	make_visible(overlay_enabled)


func _on_main_screen_changed(screen):
	overlay_enabled = false
	make_visible(false)


func _on_selection_changed():
	var sel = get_editor_interface().get_selection().get_selected_nodes()
	if sel.size() == 0 || !_handles(sel[-1]):
		enable_button.hide()
		overlay_enabled = false
		make_visible(false)
		
	else:
		enable_button.show()


func _on_editor_resized():
	editor_view.size = editor_2d_vp.size
	editor_view.global_position = editor_2d_vp.global_position
