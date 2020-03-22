
const predefined_func_settings = [
	["f", Color(1, 1, 0)],
	["g", Color(0, 1, 0)],
	["h", Color(1, 0, 1)],
	["i", Color(0, 1, 1)],
	["j", Color(1, 0, 0)],
	["k", Color(0.2, 0.4, 1)],
	["l", Color(1, 0.5, 0)],
	["m", Color(0, 0.5, 1)]
]

class Function:
	var name = ""
	var formula = ""
	var color = Color(1, 1, 0)


class Cursor:
	var name = ""
	var value = 0.0
	var min_value = 0.0
	var max_value = 1.0
	var step = 0.1


var _functions = {}
var _cursors = {}


static func get_index_from_preset_function_name(fname):
	for i in len(predefined_func_settings):
		if predefined_func_settings[i][0] == fname:
			return i
	return -1


func get_function_names() -> Array:
	return _functions.keys()


func get_function_list():
	return _functions.values()


func get_function_count():
	return len(_functions)


func get_function_by_name(fname):
	return _functions[fname]

func try_get_function_by_name(fname):
	if _functions.has(fname):
		return _functions[fname]
	return null


func has_function(fname):
	return _functions.has(fname)


func create_function(fname):
	assert(not _functions.has(fname))
	var f = Function.new()
	f.name = fname
	_functions[fname] = f
	return f


func remove_function(fname):
	_functions.erase(fname)


func create_cursor(cname):
	assert(not _cursors.has(cname))
	var c = Cursor.new()
	c.name = cname
	_cursors[cname] = c
	return c


func has_cursor(cname: String):
	return _cursors.has(cname)


func get_cursor_names() -> Array:
	return _cursors.keys()


func get_cursor_list() -> Array:
	return _cursors.values()


func get_cursor_by_name(cname: String) -> Cursor:
	return _cursors[cname]


func remove_cursor(cname: String):
	_cursors.erase(cname)

