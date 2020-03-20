extends Control


var _expression = Expression.new()
var _error = ERR_UNAVAILABLE
var _view_scale = Vector2(100, 100)
var _view_offset = Vector2(0, 0)


func _draw():
	
	var size = rect_size
	var step_x = 1.0 / _view_scale.x
	var step_y = 1.0 / _view_scale.y
	
	draw_set_transform(size / 2, 0, Vector2(_view_scale.x, -_view_scale.y))
	
	var xcolor = Color(1, 0.5, 0.5)
	var ycolor = Color(0.5, 1.0, 0.5)
	
	draw_line(Vector2(-size.x, 0), Vector2(size.x, 0), xcolor)
	draw_line(Vector2(0, -size.y), Vector2(0, size.y), ycolor)
	
	var col = Color(1, 1, 0)
	var prev_y = null
	if _error == OK:
		for i in range(-size.x, size.x):
			var x = float(i) / _view_scale.x
			var y = _expression.execute([x], null, false)
			if (typeof(y) == TYPE_REAL or typeof(y) == TYPE_INT) \
			and (not is_nan(y)) and (not is_inf(y)) and prev_y != null:
				draw_line(Vector2(x - step_x, prev_y), Vector2(x, y), col)
			prev_y = y

	draw_line(Vector2(1, -4 * step_y), Vector2(1, 4 * step_y), xcolor)
	draw_line(Vector2(-4 * step_x, 1), Vector2(4 * step_x, 1), ycolor)


func _on_LineEdit_text_entered(new_text):
	_error = _expression.parse(new_text, PoolStringArray(["x"]))
	update()

