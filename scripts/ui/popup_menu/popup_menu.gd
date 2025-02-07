class_name MenuFlyout
extends Control


@export var label: Label
@export var container: Container


var title: String = "Menu Flyout":
	set(value):
		title = value
		label.text = title


var _max_columns: int
var _offset: Vector2 = Vector2(100, 0)


func _ready() -> void:
	scale = Vector2.ZERO
	hide()


func popup(origin: Control) -> void:
	show()
	pivot_offset = Vector2(0, size.y / 2)
	var tween = create_tween()
	global_position = origin.global_position + _offset
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.08)
	tween.chain().tween_property(self, "scale", Vector2.ONE, 0.1)
	await tween.finished


func dispose() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.06)
	tween.chain().tween_property(self, "scale", Vector2.ZERO, 0.1)
	await tween.finished
	queue_free()


func add_content(control: Control) -> void:
	if control not in container.get_children():
		container.add_child(control)
		
