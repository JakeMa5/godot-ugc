extends Node

var current_level: Level:
	set(value):
		if value == current_level:
			return
			
		if current_level:
			current_level.queue_free()
			
		current_level = value
		add_child(current_level)


func _ready() -> void:
	if not DirAccess.dir_exists_absolute("user://levels"):
		DirAccess.make_dir_absolute("user://levels")
