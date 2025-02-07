class_name Cursor
extends Area2D
## Base class for a player-controlled cursor in the builder.


## Emitted when the cursor is placed over a [LevelObject] node.
signal object_hovered(obj: LevelObject)

## Emitted when the cursor is removed from a [LevelObject] node.
signal object_unhovered(obj: LevelObject)

## Emitted when the cursor is about to be destroyed.
signal disposed


## The default texture to be used for the cursor.
@export var texture: Texture2D
## The offset of the texture compared to the OS default mouse pointer.
@export var texture_offset: Vector2 = Vector2(6, 12)


var _sprite: Sprite2D
var _canvas: CanvasLayer


func _ready() -> void:
	# create the initial cursor image
	_sprite = Sprite2D.new()
	_sprite.texture = texture
	_sprite.offset = texture_offset
	
	_canvas = CanvasLayer.new()
	_canvas.layer = 128
	add_child(_canvas)
	
	_canvas.add_child(_sprite)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	_setup_colliders()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		position = get_global_mouse_position()
		_sprite.position = get_global_transform_with_canvas().get_origin()


func _on_body_entered(other: CollisionObject2D) -> void:
	if other is not LevelObject: return 
	object_hovered.emit(other)


func _on_body_exited(other: CollisionObject2D) -> void:
	if other is not LevelObject: return
	object_unhovered.emit(other)
	
	
func _setup_colliders() -> void:
	var col = CollisionShape2D.new()
	col.shape = CircleShape2D.new()
	col.position = Vector2(0, 2)
	add_child(col)
	

func dispose() -> void:
	disposed.emit()
	queue_free()
