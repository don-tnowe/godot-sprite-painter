class_name ImageScript
extends Node

## Base class for scripts that process images through Sprite painter.
##
## Extend this script and add the new file to `res://addons/sprite_painter/image_scripts/`
## to make it usable in Sprite Painter.

enum {
## Checkbox property. No hints.
	SCRIPT_PARAM_BOOL,
## Integer number property. Hints: [MINVALUE, MAXVALUE]
	SCRIPT_PARAM_INT,
## Float number property. Hints: [MINVALUE, MAXVALUE]
	SCRIPT_PARAM_FLOAT,
## Enumeration property. Hint is an array of names for the created OptionButton.
	SCRIPT_PARAM_ENUM,
## Enumeration property. Hint is an dictionary of {ICON : TOOLTIP} pairs.
## ICON can be a theme icon or a loaded Texture.
	SCRIPT_PARAM_ICON_ENUM,
## Array of Bools property. Hint is an dictionary of {ICON : TOOLTIP} pairs.
## ICON can be a theme icon or a loaded Texture.
	SCRIPT_PARAM_ICON_FLAGS,
## Resource property. Hint is the base type of accepted Resources.
	SCRIPT_PARAM_RESOURCE,
}

var _params = {}

## Returns a parameter set through the GUI.
##
## Key must be same as passed in `_get_param_list()`.
func get_param(key : String) -> Variant:
	return _params[key]


## Edits the image. Must return the result, which can be the same image object.
func _get_image(new_image : Image) -> Image:
	return new_image

## Must return a list of parameters. Each parameter contains:
##
## - Name
##
## - Type
##
## - Default
##
## - Type Hint, for which refer to ImageScript's class.
func _get_param_list():
	return [
		[
			"_get_param_list() Not overriden!",
			SCRIPT_PARAM_ENUM,
			0,
			["Refer to the ImageScript class for more info."]
		],
	]
