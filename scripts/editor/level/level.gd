class_name Level
extends Node


var _info: LevelInfo
var _data: Array = []


func _ready() -> void:
	add_child(LevelDebug.new(self))


func append_object(object: Variant) -> void:
	_data.append(object)
	add_child(object)
