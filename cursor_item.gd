extends Control

signal clicked
signal value_changed(new_value)


onready var _label := $HB/Label as Label
onready var _slider := $HB/HSlider as HSlider
onready var _spinbox := $HB/SpinBox as SpinBox
onready var _selected_bg := $SelectionBG as ColorRect


func get_item_name() -> String:
	return _label.text


func set_item_name(cname: String):
	_label.text = cname


func set_cursor_range(min_value: float, max_value: float, step: float):
	_spinbox.min_value = min_value
	_spinbox.max_value = max_value
	_spinbox.step = step
	
	_slider.min_value = min_value
	_slider.max_value = max_value
	_slider.step = step
	

func set_cursor_value(new_value: float):
	_spinbox.value = new_value


func get_cursor_value() -> float:
	return _spinbox.value


func set_selected(s: bool):
	_selected_bg.visible = s


func _on_SpinBox_value_changed(value: float):
	_slider.value = value
	emit_signal("value_changed", value)


func _on_HSlider_value_changed(value: float):
	_spinbox.value = value


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT:
				emit_signal("clicked")
