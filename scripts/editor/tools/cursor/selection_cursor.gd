class_name SelectionCursor
extends Area2D

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

		if _is_dragging and _selected_object:
			_selected_object.position = position - _drag_offset


	if event.is_action_pressed("ui_accept"):
		if _hovered_object:
			if not _selected_object:
				_select_object(_hovered_object)
			if _selected_object:
				_start_dragging()

	if event.is_action_released("ui_accept"):
		_stop_dragging()


func _on_body_entered(other: PhysicsBody2D) -> void:
	if other is LevelObject:
		_hovered_object = other


func _on_body_exited(other: PhysicsBody2D) -> void:
	if other is LevelObject:
		_hovered_object = null


func _select_object(object: LevelObject) -> void:
	_selected_object = object
	_hovered_object = null
	_drag_offset = position - _selected_object.position
	object.freeze = true


func _start_dragging() -> void:
	_is_dragging = true
	_drag_offset = position - _selected_object.position


func _stop_dragging() -> void:
	_is_dragging = false
	if _selected_object:
		_selected_object.freeze = false
		_selected_object = null
