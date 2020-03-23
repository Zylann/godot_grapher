extends ConfirmationDialog

onready var _min_value_spinbox = $GridContainer/MinValueSpinBox
onready var _max_value_spinbox = $GridContainer/MaxValueSpinBox
onready var _step_spinbox = $GridContainer/StepSpinBox

var _cursor = null


func set_cursor(cursor):
	_cursor = cursor
	_min_value_spinbox.value = cursor.min_value
	_max_value_spinbox.value = cursor.max_value
	_step_spinbox.value = cursor.step
	window_title = str("Edit cursor `", cursor.name, "`")
	

func _on_MinValueSpinBox_value_changed(value):
	pass # Replace with function body.


func _on_MaxValueSpinBox_value_changed(value):
	pass # Replace with function body.


func _on_StepSpinBox_value_changed(value):
	pass # Replace with function body.


func _on_CursorDialog_confirmed():
	_cursor.min_value = _min_value_spinbox.value
	_cursor.max_value = _max_value_spinbox.value
	_cursor.step = _step_spinbox.value
