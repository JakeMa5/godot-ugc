class_name BuilderDebug
extends Node


var _show_save_window: Array[bool] = [false]
var _level_filename: Array[String] = [""]


func _process(_delta: float) -> void:
	if ImGui.BeginMainMenuBar():
		if ImGui.BeginMenu("Builder"):
			
			if ImGui.BeginMenu("New"):
				
				if ImGui.MenuItem("Empty"):
					GameManager.current_level = Level.new()
				
				ImGui.EndMenu()
			
			if ImGui.BeginMenu("Open"):
				for file in DirAccess.get_files_at("user://levels/"):
					if ImGui.MenuItem(file):
						var data_file = FileAccess.open("user://levels/%s" % file, FileAccess.READ)
						var lvl = Level.new()
						data_file.close()
						GameManager.current_level = lvl
				ImGui.EndMenu()

			if ImGui.MenuItem("Save"):
				_show_save_window[0] = true
				
			ImGui.EndMenu()
	
		ImGui.EndMainMenuBar()
		
	if _show_save_window[0]:
		_draw_save_window()


func _draw_save_window() -> void:
	if ImGui.Begin("Save Level", _show_save_window):
		ImGui.InputText("File name", _level_filename, 16)
		if ImGui.Button("Save"):
			var file = FileAccess.open("user://levels/%s.lvl" % _level_filename[0], FileAccess.WRITE)
			file.store_var(GameManager.current_level._data)
			file.close()
		ImGui.End()
