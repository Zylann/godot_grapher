extends Control

const ProjectData = preload("./project_data.gd")

onready var _outliner = $VB/HSplit/Outliner
onready var _graph_view = $VB/HSplit/VBRight/Graph


var _project : ProjectData = null


func _ready():
	_project = ProjectData.new()
	_outliner.set_project(_project)
	_graph_view.set_project(_project)


func _on_FormulaEdit_formula_entered(new_text):
	var fname = "f"
	var f
	if not _project.has_function(fname):
		f = _project.create_function(fname)
	else:
		f = _project.get_function_by_name(fname)
	f.name = fname
	f.formula = new_text
	f.error = f.expression.parse(f.formula, PoolStringArray(["x"]))
	_outliner.update_list()
	_graph_view.update()


