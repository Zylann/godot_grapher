extends Control

const ProjectData = preload("./project_data.gd")

const _predefined_func_names = [
	"f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p"
]
const _predefined_colors = [
	Color(1, 1, 0),
	Color(0, 1, 0),
	Color(1, 0, 1),
	Color(0, 1, 1),
	Color(1, 0, 0),
	Color(0.2, 0.4, 1),
	Color(1.0, 0.5, 0),
]

onready var _outliner = $VB/HSplit/Outliner
onready var _graph_view = $VB/HSplit/VBRight/Graph
onready var _formula_edit = $VB/HSplit/VBRight/FormulaEdit


var _project : ProjectData = null


func _ready():
	_project = ProjectData.new()
	_outliner.set_project(_project)
	_graph_view.set_project(_project)


func _on_FormulaEdit_formula_entered(new_text):
	var fname = _outliner.get_selected_function_name()
	if fname == "":
		fname = _predefined_func_names[0]
	var f
	if not _project.has_function(fname):
		f = _project.create_function(fname)
	else:
		f = _project.get_function_by_name(fname)
	f.formula = new_text
	f.error = f.expression.parse(f.formula, PoolStringArray(["x"]))
	_outliner.update_list()
	_graph_view.update()


func _on_AddFunctionButton_pressed():
	var fname = ""
	for it_fname in _predefined_func_names:
		if not _project.has_function(it_fname):
			fname = it_fname
			break
	if fname == "":
		# TODO Ask for function name
		print("No function name available")
		return
	var color
	var color_index = _project.get_function_count()
	if color_index < len(_predefined_colors):
		color = _predefined_colors[color_index]
	else:
		# TODO Distance based color selection
		color = Color(randf(), randf(), randf())
	var f = _project.create_function(fname)
	f.color = color
	_outliner.update_list()
	_outliner.select_function(fname, true)
	_graph_view.update()


func _on_Outliner_function_selected(fname):
	var f = _project.get_function_by_name(fname)
	_formula_edit.set_function_name(fname)
	_formula_edit.set_text(f.formula)
