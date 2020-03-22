extends Control

const ProjectData = preload("./project_data.gd")

const _predefined_func_settings = [
	["f", Color(1, 1, 0)],
	["g", Color(0, 1, 0)],
	["h", Color(1, 0, 1)],
	["i", Color(0, 1, 1)],
	["j", Color(1, 0, 0)],
	["k", Color(0.2, 0.4, 1)],
	["l", Color(1, 0.5, 0)],
	["m", Color(0, 0.5, 1)]
]

#const _predefined_cursor_names = [
#	"a", "b", "c", "d", "e"
#]

onready var _outliner = $VB/HSplit/Outliner
onready var _graph_view = $VB/HSplit/VBRight/Graph
onready var _formula_edit = $VB/HSplit/VBRight/FormulaEdit


var _project : ProjectData = null


func _ready():
	_project = ProjectData.new()
	_outliner.set_project(_project)
	_graph_view.set_project(_project)


func _on_FormulaEdit_formula_entered(new_text):
	if _project.get_function_count() == 0:
		_create_function(new_text)
		return
	
	var fname = _outliner.get_selected_function_name()
	if fname == "":
		_create_function(new_text)
		return
	
	var f = _project.get_function_by_name(fname)
	f.formula = new_text
	f.error = f.expression.parse(f.formula, PoolStringArray(["x"]))
	_outliner.update_list()
	_graph_view.update()


func _on_AddFunctionButton_pressed():
	_create_function("")


func _create_function(formula : String):
	var fsettings = null
	for it in _predefined_func_settings:
		if not _project.has_function(it[0]):
			fsettings = it
			break
	if fsettings == null:
		# TODO Ask for function name?
		print("No function name available")
		return
	
	var fname = fsettings[0]
	var color = fsettings[1]
	
	var f = _project.create_function(fname)
	f.color = color
	if formula != "":
		f.formula = formula
		f.error = f.expression.parse(f.formula, PoolStringArray(["x"]))

	_outliner.update_list()
	_outliner.select_function(fname, true)
	_graph_view.update()


func _on_Outliner_function_selected(fname):
	var f = _project.get_function_by_name(fname)
	_formula_edit.set_function_name(fname)
	_formula_edit.set_text(f.formula)


