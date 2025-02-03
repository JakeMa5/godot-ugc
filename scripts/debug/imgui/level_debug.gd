class_name LevelDebug
extends Node

var _level: Level


func _init(level: Level) -> void:
	_level = level


func _process(_delta: float) -> void:
	if ImGui.BeginMainMenuBar():
		if ImGui.BeginMenu("Level"):
			
			if ImGui.BeginMenu("GameObject"):
				
				if ImGui.BeginMenu("Procedural Shape"):
					
					if ImGui.MenuItem("Square"):
						var obj = ProceduralShape.new()
						_level.append_object(obj)
						
					if ImGui.MenuItem("Triangle"):
						var obj = ProceduralShape.new([
								Vector2(100, 100),
								Vector2(200, 100),
								Vector2(150, 50)])
						_level.append_object(obj)
						
					if ImGui.MenuItem("Pentagon"):
						var obj = ProceduralShape.new([
								Vector2(150, 50),
								Vector2(200, 125),
								Vector2(175, 200),
								Vector2(125, 200),
								Vector2(100, 125)])
						_level.append_object(obj)
						
					if ImGui.MenuItem("Hexagon"):
						var obj = ProceduralShape.new([
								Vector2(150, 50),
								Vector2(200, 85),
								Vector2(200, 135),
								Vector2(150, 170),
								Vector2(100, 135),
								Vector2(100, 85)])
						_level.append_object(obj)
						
					if ImGui.MenuItem("Circle"):
						var num_vertices = 30
						var radius = 100
						var center = Vector2(200, 200)
						var verts = []

						for i in range(num_vertices):
							var angle = i * 2 * PI / num_vertices
							var x = center.x + radius * cos(angle)
							var y = center.y + radius * sin(angle)
							verts.append(Vector2(x, y))
						var obj = ProceduralShape.new(verts)
						_level.append_object(obj)
					
					ImGui.EndMenu()
			
				if ImGui.BeginMenu("Controllable"):
					if ImGui.MenuItem("Player"):
						var obj = load("res://scripts/player/player.tscn").instantiate()
						_level.append_object(obj)
					ImGui.EndMenu()
			
				ImGui.EndMenu()
				
			ImGui.EndMenu()
		ImGui.EndMainMenuBar()
