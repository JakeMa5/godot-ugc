class_name MaterialBrushCursor
extends Cursor


enum State {
	NONE,
	HOVERING,
}


@export var material_edit_texutre: Texture2D

@export var change_material_audio_stream: AudioStream

@export var materials_list: Array[ProceduralMaterial]


var _state: State = State.NONE
var _current_object: LevelObject
var _editing_shape: ProceduralShape
var _audio_player: AudioStreamPlayer
var _material_index: int


func _ready() -> void:
	super()
	object_hovered.connect(_on_object_hovered)
	object_unhovered.connect(_on_object_unhovered)
	_audio_player = AudioStreamPlayer.new()
	add_child(_audio_player)
	
	
func _process(delta: float) -> void:
	match _state:
		State.NONE:
			none()
			
		State.HOVERING:
			hover()


func _input(event: InputEvent) -> void:
	super(event)
	match _state:
		State.NONE:
			input_none(event)
		
		State.HOVERING:
			input_hover(event)


func none() -> void:
	pass
	

func hover() -> void:
	pass


func input_none(event: InputEvent) -> void:
	pass
	
	
func input_hover(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if _current_object is not ProceduralShape:
			return
			
		if _editing_shape:
			return
			
		_current_object.proc_material = materials_list.pick_random()
		
		if change_material_audio_stream:
			_audio_player.stream = change_material_audio_stream
			_audio_player.play()
		


func input_edit(event: InputEvent) -> void:
	pass


func _on_object_hovered(obj: LevelObject) -> void:
	if _state == State.NONE:
		_state = State.HOVERING
	_current_object = obj
	
	if obj is ProceduralShape and _state == State.HOVERING:
		_sprite.texture = material_edit_texutre


func _on_object_unhovered(_obj: LevelObject) -> void:
	if _state == State.HOVERING:
		_state = State.NONE
		_sprite.texture = texture
	
	_current_object = null
