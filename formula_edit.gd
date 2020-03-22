extends Control

signal formula_entered(new_text)

onready var _label = $HB/Label


func _on_LineEdit_text_entered(new_text):
	emit_signal("formula_entered", new_text)
