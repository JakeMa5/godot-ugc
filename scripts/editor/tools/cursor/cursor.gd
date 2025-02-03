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
		# If dragging, update the selected object's position
		if _is_dragging and _selected_object:
			_selected_object.position = position - _drag_offset

	# Handle selection when the action is triggered
	if event.is_action_pressed("ui_accept"):
		if _hovered_object:
			# If nothing is selected, select the hovered object
			if not _selected_object:
				_select_object(_hovered_object)
			# If already selected, start dragging
			if _selected_object:
				_start_dragging()

	if event.is_action_released("ui_accept"):
		# Stop dragging when the action is released
		_stop_dragging()


func _on_body_entered(other: PhysicsBody2D) -> void:
	# Ensure the object is a LevelObject
	if other is LevelObject:
		_hovered_object = other


func _on_body_exited(other: PhysicsBody2D) -> void:
	# Reset the hovered object when we stop hovering over it
	if other is LevelObject:
		_hovered_object = null


# Select the hovered object
func _select_object(object: LevelObject) -> void:
	_selected_object = object
	_hovered_object = null  # Clear the hovered object, as it's now selected
	_drag_offset = position - _selected_object.position
	object.freeze = true


# Start dragging the selected object
func _start_dragging() -> void:
	_is_dragging = true
	_drag_offset = position - _selected_object.position


# Stop dragging the selected object
func _stop_dragging() -> void:
	_is_dragging = false
	if _selected_object:
		_selected_object.freeze = false
		_selected_object = null
