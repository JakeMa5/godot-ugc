class_name ShapeCursor
extends Cursor


enum State {
	NONE,
	HOVERING,
	EDITING
}


@export var shape_edit_texutre: Texture2D
@export var vert_edit_texture: Texture2D


@export var enter_vertex_editor_audio_stream: AudioStream
@export var exit_vertex_editor_audio_stream: AudioStream


var _state: State = State.NONE
var _current_object: LevelObject
var _editing_shape: ProceduralShape
var _audio_player: AudioStreamPlayer
var _vert_editor: VertexEditor


func _ready() -> void:
	super()
	object_hovered.connect(_on_object_hovered)
	object_unhovered.connect(_on_object_unhovered)
	disposed.connect(_on_edit_cancelled)
	_audio_player = AudioStreamPlayer.new()
	add_child(_audio_player)
	
	
func _process(delta: float) -> void:
	match _state:
		State.NONE:
			none()
			
		State.HOVERING:
			hover()
			
		State.EDITING:
			edit()


func _input(event: InputEvent) -> void:
	super(event)
	match _state:
		State.NONE:
			input_none(event)
		
		State.HOVERING:
			input_hover(event)
			
		State.EDITING:
			input_edit(event)


func none() -> void:
	pass
	

func hover() -> void:
	pass
	
	
func edit() -> void:
	_sprite.texture = vert_edit_texture
	if _editing_shape:
		return

	_editing_shape = _current_object
	_vert_editor = VertexEditor.new(_editing_shape._poly)
	_vert_editor.completed_transaction.connect(_on_edit_completed)
	_editing_shape.add_child(_vert_editor)
	_editing_shape.shape_visible = false
	_editing_shape.apply_central_impulse()
	_editing_shape.freeze = true


func input_none(event: InputEvent) -> void:
	pass
	
	
func input_hover(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if _current_object is not ProceduralShape:
			return
			
		if _editing_shape:
			return
		
		if enter_vertex_editor_audio_stream:
			_audio_player.stream = enter_vertex_editor_audio_stream
			_audio_player.play()
		
		_state = State.EDITING


func input_edit(event: InputEvent) -> void:
	pass


func _on_object_hovered(obj: LevelObject) -> void:
	if _state == State.NONE:
		_state = State.HOVERING
	_current_object = obj
	
	if obj is ProceduralShape and _state == State.HOVERING:
		_sprite.texture = shape_edit_texutre


func _on_object_unhovered(_obj: LevelObject) -> void:
	if _state == State.HOVERING:
		_state = State.NONE
		_sprite.texture = texture
	
	_current_object = null
	
	
func _on_edit_completed(data: PackedVector2Array) -> void:
	if exit_vertex_editor_audio_stream:
		_audio_player.stream = exit_vertex_editor_audio_stream
		_audio_player.play()
	
	_editing_shape.verticies = data
	_editing_shape.shape_visible = true
	_editing_shape.apply_central_impulse()
	_editing_shape.freeze = false
	_editing_shape = null
	_state = State.NONE
	_vert_editor = null
	
	
func _on_edit_cancelled() -> void:
	if _vert_editor:
		_vert_editor.queue_free()
		_vert_editor = null
	
	if _editing_shape:
		_editing_shape.shape_visible = true
		_editing_shape.apply_central_impulse()
		_editing_shape.freeze = false
		_editing_shape = null
	_state = State.NONE
