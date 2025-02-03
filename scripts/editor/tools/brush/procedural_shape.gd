class_name ProceduralShape
extends LevelObject


var _is_editing: bool = false
var _poly: Polygon2D
var _collision: CollisionPolygon2D
var _verticies: PackedVector2Array


func _init(verticies=[
		Vector2(100, 100),
		Vector2(200, 100),
		Vector2(200, 200),
		Vector2(100, 200)
	]) -> void:
		self._verticies = verticies


func _ready() -> void:
	_poly = Polygon2D.new()
	_poly.polygon = _verticies
	
	_poly.antialiased = true
	
	_collision = CollisionPolygon2D.new()
	_update_collision()
	
	add_child(_poly)
	add_child(_collision)


func cursor_select() -> void:
	if _is_editing: return
	_is_editing = true
	var shape_editor = ShapeEditor.new(_poly.polygon)
	shape_editor.finished_transaction.connect(_on_shape_edit)
	_poly.hide()
	add_child(shape_editor)
	super()


func _on_shape_edit(vertices: Array) -> void:
	_poly.polygon = vertices
	_is_editing = false
	_update_collision()
	_poly.show()


func _update_collision() -> void:
	_collision.polygon = _poly.polygon
