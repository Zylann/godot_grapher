extends Control

signal clicked

onready var _label = $HBoxContainer/Label
onready var _color_dot = $HBoxContainer/CenterContainer/TextureRect
onready var _selection_bg = $SelectionBg

var _function_name = ""


func get_item_name():
	return _function_name


func set_color(color):
	_color_dot.modulate = color


func set_label(fname, formula):
	_function_name = fname
	_label.text = str(fname, "(x) = ", formula)


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT:
				emit_signal("clicked")


func set_selected(s):
	_selection_bg.visible = s

