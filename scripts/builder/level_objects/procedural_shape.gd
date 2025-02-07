class_name ProceduralShape
extends LevelObject

## Easy access to polygon verticies.
var verticies: PackedVector2Array:
	set(value):
		_poly.polygon = value
		_force_sync_collision()
	get():
		return _poly.polygon

## Easy access to polygon visibility.
var shape_visible: bool:
	set(value):
		if value:
			_poly.show()
		else:
			_poly.hide()


## Easy access to procedural material.
var proc_material: ProceduralMaterial:
	set(value):
		proc_material = value
		_poly.texture = proc_material.texture
		physics_material_override = proc_material.preset.physics_material


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
	
	_poly.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	
	_collision = CollisionPolygon2D.new()
	_force_sync_collision()
	
	add_child(_poly)
	add_child(_collision)
	
	
func _force_sync_collision() -> void:
	_collision.polygon = _poly.polygon
