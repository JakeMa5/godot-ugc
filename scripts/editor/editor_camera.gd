class_name BuilderCamera
extends Camera2D

#signal panning(value: Vector2)
#signal zooming(value: Vector2)

@export var pan_speed: float = 16.0
@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.1
@export var max_zoom: float = 3.0

func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		position.x -= pan_speed
	if Input.is_action_pressed("ui_right"):
		position.x += pan_speed
	if Input.is_action_pressed("ui_up"):
		position.y -= pan_speed
	if Input.is_action_pressed("ui_down"):
		position.y += pan_speed
		
	if Input.is_action_pressed("ui_zoom_in"):
		zoom_in_out(zoom_speed)

	elif Input.is_action_pressed("ui_zoom_out"):
		zoom_in_out(-zoom_speed)

func zoom_in_out(value: float) -> void:
	zoom.x += value * zoom_speed
	zoom.y += value * zoom_speed
	
	zoom.x = clamp(zoom.x, min_zoom, max_zoom)
	zoom.y = clamp(zoom.y, min_zoom, max_zoom)
