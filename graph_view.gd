extends Control

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
	var size = rect_size
	var step_x = 1.0 / _view_scale.x
	var step_y = 1.0 / _view_scale.y
	
	var pixel_view_offset = Vector2(-_view_offset.x, _view_offset.y) * _view_scale
	draw_set_transform(size / 2 + pixel_view_offset, 0, Vector2(_view_scale.x, -_view_scale.y))
	
	_draw_grid()
	
	if _project == null:
		return
	
	var functions = _project.get_function_list()
	
	for f in functions:
		if f.error != OK:
			continue
		
		var prev_y = null
		
		var pixel_x_min = -size.x - pixel_view_offset.x
		var pixel_x_max = size.x - pixel_view_offset.x
		
		for i in range(pixel_x_min, pixel_x_max):
			var x = float(i) / _view_scale.x
			var y = f.expression.execute([x], null, false)
			if (typeof(y) == TYPE_REAL or typeof(y) == TYPE_INT) \
			and (not is_nan(y)) and (not is_inf(y)) and prev_y != null:
				draw_line(Vector2(x - step_x, prev_y), Vector2(x, y), f.color)
			prev_y = y


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

