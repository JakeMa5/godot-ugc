class_name LevelObject
extends RigidBody2D

func cursor_select() -> void:
	sleeping = true
	
func cursor_deselect() -> void:
	sleeping = false
