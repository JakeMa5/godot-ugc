extends Button


@export var popup_menu_scene: PackedScene

@export var opened_audio_stream: AudioStream
@export var closed_audio_stream: AudioStream
@export var clicked_audio_stream: AudioStream


var _popup: MenuFlyout
var _menu_items: Array[ToolboxItem]
var _audio_player: AudioStreamPlayer


func _ready() -> void:
	_menu_items.append_array([
		ToolboxItem.new("Square", load("res://assets/icons/shapes/square.png"), Callable(_create_object).bind([])),
		ToolboxItem.new("Triangle", load("res://assets/icons/shapes/triangle.png"), Callable(_create_object).bind([Vector2(100, 100), Vector2(200, 100), Vector2(150, 50)])),
		ToolboxItem.new("Circle", load("res://assets/icons/shapes/circle.png"), Callable(_create_object).bind(_create_circle()))
	])
	toggled.connect(_on_pressed)
	focus_mode = FocusMode.FOCUS_NONE
	_audio_player = AudioStreamPlayer.new()
	add_child(_audio_player)


func _on_pressed(toggled_on: bool) -> void:
	if toggled_on:
		if not _popup:
			_audio_player.stream = opened_audio_stream
			_audio_player.play()
			_popup = popup_menu_scene.instantiate()
			_popup.title = "Toolbox"
			_create_menu_content()
			add_child(_popup)
			_popup.popup(self)
	else:
		_audio_player.stream = closed_audio_stream
		_audio_player.play()
		_popup.dispose()
		_popup = null
		

func _create_menu_content() -> void:
	for item in _menu_items:
		var button := Button.new()
		button.custom_minimum_size = Vector2(96, 96)
		button.icon = item.icon
		button.expand_icon = true
		button.tooltip_text = item.name
		button.focus_mode = FocusMode.FOCUS_NONE
		button.pressed.connect(item.action)
		_popup.add_content(button)


func _create_object(data: PackedVector2Array) -> void:
	var obj: ProceduralShape
	if data.is_empty():
		obj = ProceduralShape.new()
	else:
		obj = ProceduralShape.new(data)
	
	get_tree().current_scene.add_child(obj)
	_audio_player.stream = clicked_audio_stream
	_audio_player.play()


func _create_circle() -> PackedVector2Array:
	var num_vertices = 30
	var radius = 100
	var center = Vector2(200, 200)
	var verts = []

	for i in range(num_vertices):
		var angle = i * 2 * PI / num_vertices
		var x = center.x + radius * cos(angle)
		var y = center.y + radius * sin(angle)
		verts.append(Vector2(x, y))
	return verts
	

class ToolboxItem:
	func _init(
			name: String,
			icon: Texture2D, 
	action: Callable) -> void:
		self.name = name
		self.icon = icon
		self.action = action
	
	var name: String
	var icon: Texture2D
	var action: Callable
