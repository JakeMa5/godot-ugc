class_name Toolbar
extends Control


@export var cursor_controller: CursorController
@export var container: Container

@export var toolbar_items: Array[ToolbarItem]


var _buttons: Array[Button] = []


func _ready() -> void:
	for item in toolbar_items:
		var button = Button.new()
		button.icon = item.icon
		button.expand_icon = true
		button.custom_minimum_size = Vector2(64, 64)
		button.focus_mode = Control.FOCUS_NONE
		button.tooltip_text = item.name
		button.connect("pressed", Callable(cursor_controller, "set_cursor").bind(item.tool_scene))
		container.add_child(button)
