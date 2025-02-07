class_name SelectionCursor
extends Cursor
## Builder cursor responsible for selecting, moving,
## resizing and deleting level objects.

enum State {
	NONE,
	HOVERING,
	DRAGGING,
	DELETING,
	PROPERTY_EDITOR,
	SCALING,
	ROTATING
}

@export_group("Textures")
## Texture to be shown when hovering over a selectable object.
@export var pointer_texture: Texture2D

## Texture to be shown when hovering over a grabbable object.
@export var grabbable_texture: Texture2D

## Texture to be shown while grabbing an object.
@export var grabbing_texture: Texture2D

## Texture to be shown when deleting an object.
@export var deleting_texture: Texture2D

## Texture to be shown when editing an object's properties.
@export var properties_texture: Texture2D

## Texture to be shown when scaling an object up/down.
@export var scale_texture: Texture2D

## Texture to be shown when rotating an object.
@export var rotate_texture: Texture2D


@export_group("Audio")
## The audio stream that plays when selecting an object.
@export var select_audio_stream: AudioStream

## The audio stream that plays when deleting an object.
@export var delete_audio_stream: AudioStream

## The audio stream that plays when dragging an object.
@export var drag_audio_stream: AudioStream

## The audio stream that plays when switching modes.
@export var switch_tool_audio_stream: AudioStream

## The audio stream that plays when increasing the scale of an object.
@export var scale_up_audio_stream: AudioStream

## The audio stream that plays when decreasing the scale of an object.
@export var scale_down_audio_stream: AudioStream


var _current_object: LevelObject = null
var _selected_objects: Array[LevelObject] = []
var _drag_offset: Vector2 = Vector2.ZERO

var _audio_player: AudioStreamPlayer

var _state: State = State.NONE:
	set(value):
		if _state == value:
			return
			
		_state = value
		
		if _state == State.NONE:
			# re-check if the cursor is hovering over a level object
			if _current_object != null:
				_state = State.HOVERING


func _ready() -> void:
	super()
	
	object_hovered.connect(_on_object_hovered)
	object_unhovered.connect(_on_object_unhovered)
	
	_audio_player = AudioStreamPlayer.new()
	add_child(_audio_player)


func _process(delta: float) -> void:
	match _state:
		State.NONE:
			_handle_none_state()
		State.HOVERING:
			_handle_hovering_state()
		State.DRAGGING:
			_handle_dragging_state()
		State.DELETING:
			_handle_deleting_state()
		State.PROPERTY_EDITOR:
			_handle_propertyeditor_state()
		State.SCALING:
			_handle_scale_state()
		State.ROTATING:
			_handle_rotate_state()


func _handle_none_state() -> void:
	_sprite.texture = texture


func _handle_hovering_state() -> void:
	if _current_object in _selected_objects:
		_sprite.texture = grabbable_texture
	else:
		_sprite.texture = pointer_texture


func _handle_dragging_state() -> void:
	_sprite.texture = grabbing_texture
	for obj in _selected_objects:
		obj.position = position - _drag_offset


func _handle_deleting_state() -> void:
	_sprite.texture = deleting_texture


func _handle_propertyeditor_state() -> void:
	_sprite.texture = properties_texture
	
	
func _handle_scale_state() -> void:
	_sprite.texture = scale_texture
	
	if not _current_object:
		_state = State.NONE
		if _audio_player.playing:
			_audio_player.stop()
	
	
func _handle_rotate_state() -> void:
	_sprite.texture = rotate_texture


# Input Handling for each state
func _input(event: InputEvent) -> void:
	super(event)
	
	match _state:
		State.NONE:
			_handle_input_none_state(event)
		State.HOVERING:
			_handle_input_hovering_state(event)
		State.DRAGGING:
			_handle_input_dragging_state(event)
		State.DELETING:
			_handle_input_deleting_state(event)
		State.PROPERTY_EDITOR:
			_handle_input_propertyeditor_state(event)
		State.SCALING:
			_handle_input_scale_state(event)
		State.ROTATING:
			_handle_input_rotate_state(event)


# When the user is idle (no hovering or dragging)
func _handle_input_none_state(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if _current_object:
			_try_select_object(_current_object)
		else:
			_selected_objects.clear()


# When the user is hovering over an object
func _handle_input_hovering_state(event: InputEvent) -> void:
	if event.is_action_pressed("tool_modifier1") and _current_object:
		if switch_tool_audio_stream:
				_audio_player.stream = switch_tool_audio_stream
				_audio_player.play()
		_state = State.DELETING
		
	elif event.is_action_pressed("tool_modifier2") and _current_object:
		if switch_tool_audio_stream:
				_audio_player.stream = switch_tool_audio_stream
				_audio_player.play()
		_state = State.PROPERTY_EDITOR
	
	elif event.is_action_pressed("ui_accept"):
		_try_select_object(_current_object)
		if _selected_objects.size() > 0:
			_state = State.DRAGGING
			
			if _current_object:
				_drag_offset = position - _current_object.position
			
			if drag_audio_stream:
				_audio_player.stream = drag_audio_stream
				_audio_player.play()
				
	if _selected_objects.size() > 0:
		if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
			_state = State.SCALING
			
		if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
			_state = State.ROTATING
			
	if not _current_object:
		_state = State.NONE


func _handle_input_dragging_state(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		for obj in _selected_objects:
			obj.world_position = position - _drag_offset
			obj.force_update_transform()
			obj.freeze = false
			obj.apply_central_impulse()
		_state = State.NONE


func _handle_input_deleting_state(event: InputEvent) -> void:
	if event.is_action_released("tool_modifier1"):
		_state = State.NONE
		
	if not _current_object:
		_state = State.NONE
		return
		
	if event.is_action_pressed("ui_accept"):
		await _current_object.dispose_with_animation()
		_current_object = null
		_state = State.NONE
		
		if delete_audio_stream:
			_audio_player.stream = delete_audio_stream
			_audio_player.play()


func _handle_input_propertyeditor_state(event) -> void:
	if event.is_action_released("tool_modifier2"):
		_state = State.NONE
		
	if not _current_object:
		_state = State.NONE
		return


func _handle_input_scale_state(event) -> void:
	if event.is_action("ui_up"):
		for obj in _selected_objects:
			for child in obj.get_children():
				if child.scale < obj.MAXIMUM_SCALE:
					child.scale += Vector2(0.1, 0.1)
					
		if scale_up_audio_stream and not _audio_player.playing:
			_audio_player.stream = scale_up_audio_stream
			_audio_player.play()

	if event.is_action("ui_down"):
		for obj in _selected_objects:
			for child in obj.get_children():
				if child.scale > obj.MINIMUM_SCALE:
					child.scale -= Vector2(0.1, 0.1)
					
		if scale_down_audio_stream and not _audio_player.playing:
			_audio_player.stream = scale_down_audio_stream
			_audio_player.play()
	
	if event.is_action_released("ui_up"):
		_state = State.NONE
		_audio_player.stop()
		
	if event.is_action_released("ui_down"):
		_state = State.NONE
		_audio_player.stop()
		
	if not _current_object:
		_state = State.NONE
		return


func _handle_input_rotate_state(event) -> void:
	if event.is_action("ui_right"):
		for obj in _selected_objects:
			obj.rotate(0.1)

	if event.is_action("ui_left"):
		for obj in _selected_objects:
			obj.rotate(-0.1)
	
	if event.is_action_released("ui_right"):
		_state = State.NONE
		
	if event.is_action_released("ui_left"):
		_state = State.NONE
		
	if not _current_object:
		_state = State.NONE
		return


func _try_select_object(obj: LevelObject) -> void:
	if obj:
		_selected_objects.clear()
		if obj not in _selected_objects:
			obj.freeze = true
			_selected_objects.append(obj)
			
			if select_audio_stream:
				_audio_player.stream = select_audio_stream
				_audio_player.play()
			
		_state = State.HOVERING


func _on_object_hovered(obj: LevelObject) -> void:
	if _state == State.NONE:
		_state = State.HOVERING
	_current_object = obj


func _on_object_unhovered(obj: LevelObject) -> void:
	if _state == State.HOVERING:
		_state = State.NONE
	_sprite.texture = texture
	
	_current_object = null


func _exit_tree() -> void:
	object_hovered.disconnect(_on_object_hovered)
	object_unhovered.disconnect(_on_object_unhovered)
