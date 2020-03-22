extends Control

signal formula_entered(new_text)

onready var _label = $HB/Label
onready var _line_edit = $HB/LineEdit


func set_function_name(fname):
	_label.text = str(fname, "(x) = ")


func set_text(text):
	_line_edit.text = text


func _on_LineEdit_text_entered(new_text):
	emit_signal("formula_entered", new_text)
