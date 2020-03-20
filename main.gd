extends Control

var _expression = Expression.new()
var _error = ERR_UNAVAILABLE
var _view_scale = Vector2(100, 100)
var _view_offset = Vector2(0, 0)


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
				_view_scale *= factor
				update()
			BUTTON_WHEEL_DOWN:
				_view_scale /= factor
				update()
	

func _pixel_to_graph_position(ppos):
	return (Vector2(ppos.x, rect_size.y - ppos.y) - rect_size / 2) / _view_scale + _view_offset


func _draw():
	
	var size = rect_size
	var step_x = 1.0 / _view_scale.x
	var step_y = 1.0 / _view_scale.y
	
	var pixel_view_offset = Vector2(-_view_offset.x, _view_offset.y) * _view_scale
	draw_set_transform(size / 2 + pixel_view_offset, 0, Vector2(_view_scale.x, -_view_scale.y))
	
	# Axis lines
	var xcolor = Color(1, 0.5, 0.5)
	var ycolor = Color(0.5, 1.0, 0.5)
	draw_line(Vector2(-size.x, 0), Vector2(size.x, 0), xcolor)
	draw_line(Vector2(0, -size.y), Vector2(0, size.y), ycolor)
	# Graduations
	draw_line(Vector2(1, -4 * step_y), Vector2(1, 4 * step_y), xcolor)
	draw_line(Vector2(-4 * step_x, 1), Vector2(4 * step_x, 1), ycolor)
	
	if _error == OK:
		var col = Color(1, 1, 0)
		var prev_y = null
		
		var pixel_x_min = -size.x - pixel_view_offset.x
		var pixel_x_max = size.x - pixel_view_offset.x
		
		for i in range(pixel_x_min, pixel_x_max):
			var x = float(i) / _view_scale.x
			var y = _expression.execute([x], null, false)
			if (typeof(y) == TYPE_REAL or typeof(y) == TYPE_INT) \
			and (not is_nan(y)) and (not is_inf(y)) and prev_y != null:
				draw_line(Vector2(x - step_x, prev_y), Vector2(x, y), col)
			prev_y = y


func _on_LineEdit_text_entered(new_text):
	_error = _expression.parse(new_text, PoolStringArray(["x"]))
	update()

