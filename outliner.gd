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
	
	var index = _functions_header.get_index() + 1
	
	for i in len(function_names):
		var fname = function_names[i]
		var f = _project.get_function_by_name(fname)
		var fi = _container.get_child(index)
		
		if not fi is FunctionItem:
			fi = FunctionItemScene.instance()
			fi.connect("clicked", self, "_on_function_item_clicked", [fi])
			_container.add_child(fi)
			_container.move_child(fi, index)
			
		fi.set_label(f.name, f.formula)
		fi.set_color(f.color)
		fi.set_selected(f.name == _selected_function_name)
		
		index += 1
	
	while index < _cursors_header.get_index():
		var child = _container.get_child(index)
		if child is FunctionItem:
			child.queue_free()
		index += 1


func _on_function_item_clicked(fi):
	select_function(fi.get_function_name(), true)


func _get_function_node_index(fname):
	for i in _container.get_child_count():
		var child = _container.get_child(i)
		if child is FunctionItem and child.get_function_name() == fname:
			return i
	return -1


func _on_RemoveFunctionButton_pressed():
	var fname = get_selected_function_name()
	if fname == "":
		print("No function selected")
		return
	
	# Select following item.
	# If not found, select preceding item.
	# If not found, clear selection.
	
	var next_selected = ""
	var removed_index = _get_function_node_index(fname)
	assert(removed_index != -1)
	for i in [removed_index + 1, removed_index - 1]:
		var child = _container.get_child(i)
		if child is FunctionItem:
			next_selected = child.get_function_name()
			break
	
	_project.remove_function(fname)
	update_list()

	if next_selected != "":
		select_function(next_selected, true)
	else:
		_selected_function_name = ""

