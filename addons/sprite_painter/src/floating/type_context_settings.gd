@tool
extends MarginContainer

var editor_plugin : EditorPlugin
var plugin_root : Node
var sprite_frames_editor_dock : Control
var tileset_editor_dock : Control

var sprite_frames_anim_list : Tree
var sprite_frames_frame_list : ItemList
var sprite_frames_anim : String
var sprite_frames_frame : int

var tileset_source_list : ItemList

var edited_object : Object


func _ready():
	hide()
	readjust_size()

	plugin_root = get_parent()
	while !plugin_root is Window:
		plugin_root = plugin_root.get_parent()
		if plugin_root is SpritePainterRoot:
			editor_plugin = plugin_root.editor_plugin
			plugin_root.object_selected.connect(_on_plugin_object_selected)
			break

	var c = Control.new()
	editor_plugin.add_control_to_bottom_panel(c, "AAA")
	for x in c.get_parent().get_children():
		if x.get_class() == "SpriteFramesEditor":
			sprite_frames_editor_dock = x
			sprite_frames_anim_list = x.get_child(0).get_child(1).get_child(0).get_child(1)
			sprite_frames_anim_list\
				.item_selected.connect(_on_spriteframes_anim_selected)
			sprite_frames_frame_list = x.get_child(1).get_child(1).get_child(0).get_child(1)
			sprite_frames_frame_list\
				.item_clicked.connect(_on_spriteframes_frame_selected)

		if x.get_class() == "TileSetEditor":
			tileset_editor_dock = x
			tileset_source_list = x.get_child(1).get_child(0).get_child(0)
			tileset_source_list\
				.item_clicked.connect(_on_tileset_source_selected)

	editor_plugin.remove_control_from_bottom_panel(c)
	_on_plugin_object_selected(editor_plugin.edited_object)


func _on_plugin_object_selected(obj):
	hide()
	if obj == null: return
	if obj is TileMap:
		_on_plugin_object_selected(obj.tile_set)
		return

	if obj is AnimatedSprite2D || obj is AnimatedSprite3D:
		_on_plugin_object_selected(obj.frames)
		return

	if obj is TileMap:
		_on_plugin_object_selected(obj.tile_set)
		return

	edited_object = obj
	if obj is SpriteFrames:
		call_deferred("update_spriteframes")

	elif obj is TileSet:
		call_deferred("update_tileset")

	else:
		return

	readjust_size()
	show()


func readjust_size():
	size = Vector2.ZERO
	position = get_parent().size - get_minimum_size()


func update_spriteframes():
	sprite_frames_anim = sprite_frames_anim_list.get_selected().get_text(0)
	sprite_frames_frame = sprite_frames_frame_list.get_selected_items()[0]
	$"Container/Box/FrameData".text = "%s : frame %s" % [sprite_frames_anim, sprite_frames_frame]

	var frame_tex = edited_object.get_frame(sprite_frames_anim, sprite_frames_frame)
	if frame_tex is AtlasTexture:
		plugin_root.edit_subresource(
			frame_tex.atlas.resource_path,
			frame_tex.region.size,
			frame_tex.region.position,
			true
		)

	else:
		plugin_root.edit_file(frame_tex.resource_path)


func update_tileset():
	var selected_id = tileset_source_list.get_selected_items()[0]
	var sauce = edited_object.get_source(selected_id)
	if !(sauce is TileSetAtlasSource):
		return

	plugin_root.edit_subresource(
		sauce.get_texture().resource_path,
		sauce.texture_region_size + sauce.separation,
		sauce.margins,
		false
	)


func _on_spriteframes_frame_selected(index, at_pos, mouse_button_index):
	update_spriteframes()


func _on_spriteframes_anim_selected():
	update_spriteframes()


func _on_tileset_source_selected(index, at_pos, mouse_button_index):
	update_tileset()


func _on_visibility_changed():
	pass
