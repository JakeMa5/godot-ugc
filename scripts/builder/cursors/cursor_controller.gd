class_name CursorController
extends Node


var _current_cursor: Cursor


@export var default: PackedScene


func _ready() -> void:
	call_deferred("set_cursor", default)


func set_cursor(cursor_scene: PackedScene):
	var inst = cursor_scene.instantiate()
	if _current_cursor:
		if inst.get_script() == _current_cursor.get_script():
			return
		
		_current_cursor.dispose()
	
	_current_cursor = inst
	get_tree().current_scene.add_child(_current_cursor)
