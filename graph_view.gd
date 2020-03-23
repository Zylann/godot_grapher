extends Control

const ProjectData = preload("./project_data.gd")

const X_AXIS_COLOR = Color(1, 0.5, 0.5)
const Y_AXIS_COLOR = Color(0.5, 1.0, 0.5)

var _view_scale = Vector2(100, 100)
var _view_offset = Vector2(0, 0)
var _grid_color = Color(1, 1, 1, 0.15)
var _grid_step = Vector2(1, 1)

var _project = null


func set_project(project):
	_project = project
	update()


func _gui_input(event):
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(BUTTON_MIDDLE):
			_view_offset += Vector2(-event.relative.x, event.relative.y) / _view_scale
			update()
		else:
			var mpos = event.position
			var gpos = _pixel_to_graph_position(mpos)
	
	elif event is InputEventMouseButton:
		var factor = 1.1
		match event.button_index:
			BUTTON_WHEEL_UP:
				_add_zoom(factor, event.position)
			BUTTON_WHEEL_DOWN:
				_add_zoom(1.0 / factor, event.position)


func _add_zoom(factor, mpos):
	var gpos = _pixel_to_graph_position(mpos)
	_view_scale *= factor
	var gpos2 = _pixel_to_graph_position(mpos)
	_view_offset += gpos - gpos2
	update()


func _pixel_to_graph_position(ppos):
	return (Vector2(ppos.x, rect_size.y - ppos.y) - rect_size / 2) / _view_scale + _view_offset


func _draw():
#	var time_before = OS.get_ticks_usec()
	
	var size = rect_size
	var step_x = 1.0 / _view_scale.x
	var step_y = 1.0 / _view_scale.y
	
	var pixel_view_offset = Vector2(-_view_offset.x, _view_offset.y) * _view_scale
	draw_set_transform(size / 2 + pixel_view_offset, 0, Vector2(_view_scale.x, -_view_scale.y))
	
	_draw_grid()
	
	if _project == null:
		return
	
	var functions = _project.get_function_list()
	
	var pixel_x_min = int(floor(-size.x * 0.5 - pixel_view_offset.x))
	var pixel_x_max = int(floor(size.x * 0.5 - pixel_view_offset.x))
	
	# Gather variables
	var cursor_names = _project.get_cursor_names()
	var var_names = PoolStringArray()
	var_names.resize(1 + len(cursor_names))
	var_names[0] = "x"
	var var_inputs = []
	var_inputs.resize(len(var_names))
	for i in len(cursor_names):
		var c = _project.get_cursor_by_name(cursor_names[i])
		var_names[i + 1] = c.name
		var_inputs[i + 1] = c.value
	
	# Gather expressions
	var expressions = []
	var indexed_funcs = []
	expressions.resize(len(ProjectData.predefined_func_settings))
	indexed_funcs.resize(len(expressions))
	for f in functions:
		var expression = Expression.new()
		var error = expression.parse(f.formula, var_names)
		if error != OK:
			#print(f.name, ": ", error)
			continue
		var i = ProjectData.get_index_from_preset_function_name(f.name)
		assert(i != -1)
		expressions[i] = expression
		indexed_funcs[i] = f
	
	var expression_context = ExpressionContext.new(expressions, var_inputs)
	var pixel_width = int(rect_size.x)
	var points = []
	points.resize(pixel_width)

	# Draw each function	
	for func_index in len(indexed_funcs):
		var expression = expressions[func_index]
		if expression == null:
			continue
		var f = indexed_funcs[func_index]
		
		var color = f.color
		var pi = 0
		#var segment_count = 0
				
		for i in range(pixel_x_min, pixel_x_max):
			var x = float(i) / _view_scale.x
			var_inputs[0] = x
			var y = expression.execute(var_inputs, expression_context, false)
			
			if expression.has_execute_failed():
				#print(expression.get_error_text())
				break
			
			if (typeof(y) == TYPE_REAL or typeof(y) == TYPE_INT) \
			and (not is_nan(y)) and (not is_inf(y)):
				points[pi] = Vector2(x, y)
				pi += 1
			else:
				if pi > 1:
					_draw_polyline(points, pi, color)
					#segment_count += 1
				pi = 0
		
		if pi > 1:
			_draw_polyline(points, pi, color)
			#segment_count += 1
		
		#print("Segment count: ", segment_count)
	
#	var time_spent = OS.get_ticks_usec() - time_before
#	print("Time: ", time_spent / 1000.0, "ms")


func _draw_polyline(points, count, color):
	var pts = PoolVector2Array()
	#    a, b, c, d, e
	# => a, b, b, c, c, d, d, e
	pts.resize((count - 2) * 2 + 2)
	pts[0] = points[0]
	var j = 1
	for i in range(1, count - 1):
		pts[j] = points[i]
		j += 1
		pts[j] = points[i]
		j += 1
	pts[len(pts) - 1] = points[count - 1]
	draw_polyline(pts, color)


func _draw_grid():
	var step = _grid_step
	var gmin = _pixel_to_graph_position(Vector2(0, rect_size.y)).snapped(step) - step
	var gmax = _pixel_to_graph_position(Vector2(rect_size.x, 0)).snapped(step) + step
	
	var counts = rect_size / (_view_scale * step)
	var max_counts = rect_size / 2
	
	if counts.x < max_counts.x:
		var x = gmin.x
		while x < gmax.x:
			draw_line(Vector2(x, gmin.y), Vector2(x, gmax.y), _grid_color)
			x += step.x
	
	if counts.y < max_counts.y:
		var y = gmin.y
		while y < gmax.y:
			draw_line(Vector2(gmin.x, y), Vector2(gmax.x, y), _grid_color)
			y += step.y

	draw_line(Vector2(gmin.x, 0), Vector2(gmax.x, 0), X_AXIS_COLOR)
	draw_line(Vector2(0, gmin.y), Vector2(0, gmax.y), Y_AXIS_COLOR)


# Oh joy, Expression's function binding is class based.
class ExpressionContext:
	var _expressions : Array
	var _var_inputs : Array
	
	func _init(expressions, var_inputs):
		_var_inputs = var_inputs
		_expressions = expressions
		
	func _internal_exec(i: int, x: float):
		var e = _expressions[i]
		if e == null:
			return
		var args = _var_inputs.duplicate()
		args[0] = x
		return e.execute(args, self, false)
		
	func f(x):
		return _internal_exec(0, x)

	func g(x):
		return _internal_exec(1, x)

	func h(x):
		return _internal_exec(2, x)

	func i(x):
		return _internal_exec(3, x)

	func j(x):
		return _internal_exec(4, x)

	func k(x):
		return _internal_exec(5, x)

	func l(x):
		return _internal_exec(6, x)

	func m(x):
		return _internal_exec(7, x)
