extends Control

const FunctionItem = preload("./function_item.gd")
const CursorItem = preload("./cursor_item.gd")
const ProjectData = preload("./project_data.gd")

const FunctionItemScene = preload("./function_item.tscn")
const CursorItemScene = preload("./cursor_item.tscn")

signal function_selected(fname)
signal cursor_changed

onready var _functions_header := $VB/Functions as Control
onready var _cursors_header := $VB/Cursors as Control
onready var _container := $VB as VBoxContainer

var _project : ProjectData
var _selected_function_name := ""
var _selected_cursor_name := ""


func set_project(project: ProjectData):
	_project = project
	update_list()


func select_function(fname: String, notify: bool):
	if _selected_function_name == fname:
		return
	_selected_function_name = fname
	for i in _container.get_child_count():
		var child = _container.get_child(i)
		if child is FunctionItem:
			child.set_selected(child.get_item_name() == fname)
	if notify:
		emit_signal("function_selected", _selected_function_name)


func select_cursor(cname: String):
	if _selected_cursor_name == cname:
		return
	_selected_cursor_name = cname
	for i in _container.get_child_count():
		var child = _container.get_child(i)
		if child is CursorItem:
			child.set_selected(child.get_item_name() == cname)


func get_selected_function_name() -> String:
	return _selected_function_name


func get_selected_cursor_name() -> String:
	return _selected_cursor_name


func update_list():
	_update_function_list()
	_update_cursors_list()


func _update_function_list():
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


func _update_cursors_list():
	var cursor_names := _project.get_cursor_names()
	cursor_names.sort()
	
	var index := _cursors_header.get_index() + 1
	
	for i in len(cursor_names):
		var cname := cursor_names[i] as String
		var c = _project.get_cursor_by_name(cname)
		
		var ci
		if index < _container.get_child_count():
			ci = _container.get_child(index)
		
		if ci == null or not (ci is CursorItem):
			ci = CursorItemScene.instance()
			ci.connect("clicked", self, "_on_cursor_item_clicked", [ci])
			ci.connect("value_changed", self, "_on_cursor_value_changed", [ci])
			_container.add_child(ci)
			_container.move_child(ci, index)
		
		ci.set_item_name(c.name)
		ci.set_cursor_range(c.min_value, c.max_value, c.step)
		ci.set_cursor_value(c.value)
		ci.set_selected(c.name == _selected_cursor_name)
		
		index += 1
	
	while index < _container.get_child_count():
		var child = _container.get_child(index)
		if child is CursorItem:
			child.queue_free()
		index += 1


func _on_function_item_clicked(fi):
	select_function(fi.get_item_name(), true)


func _get_item_node_index(fname: String, klass) -> int:
	for i in _container.get_child_count():
		var child = _container.get_child(i)
		if child is klass and child.get_item_name() == fname:
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
	
	var next_selected := ""
	var removed_index := _get_item_node_index(fname, FunctionItem)
	assert(removed_index != -1)
	for i in [removed_index + 1, removed_index - 1]:
		var child = _container.get_child(i)
		if child is FunctionItem:
			next_selected = child.get_item_name()
			break
	
	_project.remove_function(fname)
	update_list()

	if next_selected != "":
		select_function(next_selected, true)
	else:
		_selected_function_name = ""


func _on_RemoveCursorButton_pressed():
	var cname = get_selected_cursor_name()
	if cname == "":
		print("No cursor selected")
		return
	
	var next_selected := ""
	var removed_index := _get_item_node_index(cname, CursorItem)
	assert(removed_index != -1)
	for i in [removed_index + 1, removed_index - 1]:
		if i >= _container.get_child_count():
			continue
		var child = _container.get_child(i)
		if child is CursorItem:
			next_selected = child.get_item_name()
			break
	
	_project.remove_cursor(cname)
	update_list()

	if next_selected != "":
		select_cursor(next_selected)
	else:
		_selected_cursor_name = ""


func _on_cursor_item_clicked(ci):
	select_cursor(ci.get_item_name())


func _on_cursor_value_changed(value, ci):
	var c = _project.get_cursor_by_name(ci.get_item_name())
	c.value = value
	emit_signal("cursor_changed")

