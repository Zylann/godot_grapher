extends Control

signal function_selected(fname)

const FunctionItem = preload("./function_item.gd")
const FunctionItemScene = preload("./function_item.tscn")


onready var _functions_header = $VB/Functions
onready var _cursors_header = $VB/Cursors
onready var _container = $VB


var _project = null
var _selected_function_name = ""


func set_project(project):
	_project = project
	update_list()


func select_function(fname, notify: bool):
	if _selected_function_name == fname:
		return
	_selected_function_name = fname
	for i in _container.get_child_count():
		var child = _container.get_child(i)
		if child is FunctionItem:
			child.set_selected(child.get_function_name() == fname)
	if notify:
		emit_signal("function_selected", _selected_function_name)


func get_selected_function_name():
	return _selected_function_name


func update_list():
	var function_names = _project.get_function_names()
	function_names.sort()
	
	for i in len(function_names):
		var fname = function_names[i]
		var f = _project.get_function_by_name(fname)
		var index = _functions_header.get_index() + 1 + i
		var fi = _container.get_child(index)
		
		if not fi is FunctionItem:
			fi = FunctionItemScene.instance()
			fi.connect("clicked", self, "_on_function_item_clicked", [fi])
			_container.add_child(fi)
			_container.move_child(fi, index)
			
		fi.set_label(f.name, f.formula)
		fi.set_color(f.color)
		
		index += 1
	

func _on_function_item_clicked(fi):
	select_function(fi.get_function_name(), true)
