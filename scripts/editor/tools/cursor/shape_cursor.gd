class_name ShapeCursor
extends Area2D
## Builder cursor that provides access to the shape editor tool.


var _hovered_object: LevelObject
var _selected_object: LevelObject
var _drag_offset: Vector2 = Vector2.ZERO
var _is_dragging: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		position = get_global_mouse_position()
	
	if event.is_action_pressed("ui_accept"):
		if _hovered_object is ProceduralShape:
			_hovered_object.cursor_select()


func _on_body_entered(other: PhysicsBody2D) -> void:
	if other is LevelObject:
		_hovered_object = other


func _on_body_exited(other: PhysicsBody2D) -> void:
	if other is LevelObject:
		_hovered_object = null
