extends Control

signal formula_entered(new_text)

onready var _label = $HB/Label
onready var _line_edit = $HB/LineEdit

# Expression has no API to tell us that list...
const _built_in_functions = {
	"sin": true,
	"cos": true,
	"tan": true,
	"sinh": true,
	"cosh": true,
	"tanh": true,
	"asin": true,
	"acos": true,
	"atan": true,
	"atan2": true,
	"sqrt": true,
	"fmod": true,
	"fposmod": true,
	"posmod": true,
	"floor": true,
	"ceil": true,
	"round": true,
	"abs": true,
	"sign": true,
	"pow": true,
	"log": true,
	"exp": true,
	#"is_nan": true,
	#"is_inf": true,
	"ease": true,
	"decimals": true,
	"step_decimals": true,
	"stepify": true,
	"lerp": true,
	"lerp_angle": true,
	"inverse_lerp": true,
	"range_lerp": true,
	"smoothstep": true,
	"move_toward": true,
	"dectime": true,
	#"randomize": true,
	"randi": true,
	"randf": true,
	"rand_range": true,
	#"seed": true,
	#"rand_seed": true,
	"deg2rad": true,
	"rad2deg": true,
	"linear2db": true,
	"db2linear": true,
	#"polar2cartesian": true,
	#"cartesian2polar": true,
	"wrapi": true,
	"wrapf": true,
	"max": true,
	"min": true,
	"clamp": true,
	"nearest_po2": true
	#"weakref": true,
	#"funcref": true,
	#"convert": true,
	#"typeof": true,
	#"type_exists": true,
	#"char": true,
	#"ord": true,
	#"str": true,
	#"print": true,
	#"printerr": true,
	#"printraw": true,
	#"var2str": true,
	#"str2var": true,
	#"var2bytes": true,
	#"bytes2var": true,
	#"color_named": true
}


var _project = null
var _function_name = ""


func set_project(project):
	_project = project


func set_function_name(fname):
	_function_name = fname
	_label.text = str(fname, "(x) = ")


func set_text(text):
	_line_edit.text = text


func _on_LineEdit_text_entered(new_text):
	if _detect_cycle(new_text):
		print("Cyclic dependency detected")
		return
	emit_signal("formula_entered", new_text)


func _detect_cycle(new_text):
	var to_process = [_function_name]
	var visited = {}
	var processed = {}
	
	while len(to_process) > 0:
		var f = to_process[-1]
		to_process.pop_back()
		visited[f] = true
		
		var formula
		if f == _function_name:
			formula = new_text
		else:
			formula = _project.get_function_by_name(f).formula
		
		var deps = _get_used_functions(formula)
		for dep in deps:
			if _built_in_functions.has(dep):
				continue
			if visited.has(dep):
				return true
			if _project.has_function(dep):
				to_process.append(dep)
	
	return false


# Expression has no API to tell which function it parsed...
static func _get_used_functions(formula):
	var funcs = []
	var last_non_identifier = -1

	for i in len(formula):
		var c = formula[i]

		# TODO Handle spaces before the bracket...
		if c == "(":
			var begin = last_non_identifier + 1
			if begin < i:
				var id = formula.substr(begin, i - begin)
				if not funcs.has(id):
					funcs.append(id)
			last_non_identifier = i

		elif not c.is_valid_identifier():
			last_non_identifier = i

	return funcs

