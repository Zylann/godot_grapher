
class Function:
	var name = ""
	var formula = ""
	var color = Color(1, 1, 0)
	# Transient
	var expression = Expression.new()
	var error = ERR_UNAVAILABLE


class Cursor:
	var name = ""
	var value = 0.0
	var min_value = 0.0
	var max_value = 1.0
	var step = 0.1


var _functions = {}
var _cursors = {}


func get_function_names():
	return _functions.keys()


func get_function_list():
	return _functions.values()


func get_function_by_name(fname):
	return _functions[fname]


func has_function(fname):
	return _functions.has(fname)


func create_function(fname):
	assert(not _functions.has(fname))
	var f = Function.new()
	f.name = fname
	_functions[fname] = f
	return f

