class_name ShapeEditor
extends Polygon2D
## Builder tool for editing the vertex points on a level shape.
##
## Handles the creation, destruction and modification of vertex coords
## on a polygon using the mouse pointer.


## Emitted when the player completes the tool transaction, returns the vertex coords
## from the edited copy of the polygon.
signal finished_transaction(data: Array)


var _vertices: Array = []
var _selected_vertex: int = -1
var _vertex_tolerance: float = 32.0
var _is_dragging: bool = false
var _hovered_vertex: int = -1

func _init(vertices=[
		Vector2(100, 100),
		Vector2(200, 100),
		Vector2(200, 200),
		Vector2(100, 200)]
	) -> void:
		self._vertices = vertices


func _ready():
	color = Color.TRANSPARENT
	update_polygon()


func update_polygon():
	polygon = _vertices
	force_update_transform()


func _draw():
	for i in range(_vertices.size()):
		var v = _vertices[i]
		draw_line(v, _vertices[(i + 1) % _vertices.size()], Color(1, 1, 1), 2, true)

		if i == _hovered_vertex:
			draw_circle(v, 8, Color(1, 1, 1))
			draw_circle(v, 5, Color.DARK_SEA_GREEN)
		else:
			draw_circle(v, 6, Color(1, 1, 1))


func _input(event):
	var pos = get_local_mouse_position()
	if event is InputEventMouseButton:
		if event.is_action_pressed("ui_accept"):
			add_vertex(pos)
			
		if event.is_action_pressed("ui_cancel"):
			finished_transaction.emit(_vertices)
			queue_free()

		if event.is_action("ui_accept"):
			if event.pressed:
				select_vertex(pos)
			else:
				_is_dragging = false
	elif event is InputEventMouseMotion:
		update_hovered_vertex(pos)
		if _is_dragging:
			move_vertex(pos)


func select_vertex(mouse_position: Vector2):
	_selected_vertex = -1
	for i in range(_vertices.size()):
		if _vertices[i].distance_to(mouse_position) < _vertex_tolerance:
			_selected_vertex = i
			_is_dragging = true
			break


func move_vertex(mouse_position: Vector2):
	if _selected_vertex != -1:
		# Move the selected vertex
		_vertices[_selected_vertex] = mouse_position
		update_polygon()


func update_hovered_vertex(mouse_position: Vector2):
	if _is_dragging: return
	
	_hovered_vertex = -1
	for i in range(_vertices.size()):
		if _vertices[i].distance_to(mouse_position) < _vertex_tolerance:
			_hovered_vertex = i
			break


func add_vertex(mouse_position: Vector2):
	if _is_dragging: return
	
	for i in range(_vertices.size()):
		if _vertices[i].distance_to(mouse_position) < _vertex_tolerance:
			return

	var closest_distance = INF
	var closest_edge_index = -1
	var closest_point = Vector2()

	for i in range(_vertices.size()):
		var start = _vertices[i]
		var end = _vertices[(i + 1) % _vertices.size()]
		
		var point_on_edge = _get_nearest_point(start, end, mouse_position)
		var distance = point_on_edge.distance_to(mouse_position)
		
		if distance < closest_distance:
			closest_distance = distance
			closest_edge_index = i
			closest_point = point_on_edge

	if closest_distance < _vertex_tolerance:
		_vertices.insert(closest_edge_index + 1, closest_point)
		_hovered_vertex = closest_edge_index + 1
		update_polygon()


func remove_vertex(mouse_position: Vector2):
	if _is_dragging: return
	
	var closest_vertex_index = -1
	var closest_distance = _vertex_tolerance

	for i in range(_vertices.size()):
		var distance = _vertices[i].distance_to(mouse_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_vertex_index = i

	if closest_vertex_index != -1 and _vertices.size() > 3:
		_vertices.erase(closest_vertex_index)
		update_polygon()


func _get_nearest_point(start: Vector2, end: Vector2, point: Vector2) -> Vector2:
	var line_dir = end - start
	var line_length = line_dir.length()
	
	if line_length == 0:
		return start  # Avoid division by zero if the line is a point
	
	line_dir = line_dir.normalized()
	
	# Project the point onto the line
	var projection = (point - start).dot(line_dir)
	projection = clamp(projection, 0, line_length)
	
	# Calculate the point on the line closest to the mouse click
	return start + line_dir * projection
