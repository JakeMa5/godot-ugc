extends Node

var current_level: Level:
	set(value):
		if value == current_level:
			return
			
		if current_level:
			current_level.queue_free()
			
		current_level = value
		add_child(current_level)
