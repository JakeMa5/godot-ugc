class_name LevelObject
extends RigidBody2D
## Defines a physical object that can be placed into the sandbox.
##
## LevelObjects can be serialized with the world save, ensuring
## that their properties are preserved when saving and loading levels.


const MAXIMUM_SCALE := Vector2(10, 10)
const MINIMUM_SCALE := Vector2(0.1, 0.1)


## Easy access for rigidbody position
var world_position: Vector2:
	set(value):
		_temp_position = value
		
	get():
		return position


var _temp_position: Vector2 = Vector2.ZERO 


func _ready() -> void:
	for child in get_children():
		if child is not CanvasItem: continue
		child.use_parent_material = true


func dispose() -> void:
	queue_free()
	
	
func dispose_with_animation() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.1)
	await tween.finished
	dispose()


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not _temp_position == Vector2.ZERO:
		state.transform = Transform2D(rotation, _temp_position)
		_temp_position = Vector2.ZERO
