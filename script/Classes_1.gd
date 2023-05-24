extends Node


#шторм unwetter
class Unwetter:
	var obj = {}
	var scene = {}


	func _init(input_):
		obj.meer = input_.meer
		#init_scene()


	func init_scene() -> void:
		scene.myself = Global.scene.unwetter.instantiate()
		scene.myself.set_parent(self)
		obj.meer.scene.myself.get_node("Unwetter").add_child(scene.myself)


#водораздел wasserscheide
class Wasserscheide:
	var arr = {}
	var obj = {}
	var scene = {}


	func _init(input_):
		obj.meer = input_.meer
		arr.pole = input_.poles
		init_scene()


	func init_scene() -> void:
		scene.myself = Global.scene.wasserscheide.instantiate()
		scene.myself.set_parent(self)
		obj.meer.scene.myself.get_node("Wasserscheide").add_child(scene.myself)



#море meer
class Meer:
	var obj = {}
	var arr = {}
	var scene = {}


	func _init():
		init_scene()
		init_wasserscheides()


	func init_scene() -> void:
		scene.myself = Global.scene.meer.instantiate()
		Global.node.game.get_node("Layer1").add_child(scene.myself)


	func init_wasserscheides() -> void:
		var corners = []
		var borders = []
		
		for _i in Global.dict.neighbor.zero.size():
			var _j = (_i+1)%Global.dict.neighbor.zero.size()
			var indexs = [_i,_j]
			var border = []
			
			for index in indexs:
				var neighbor = Global.dict.neighbor.zero[index]
				var vertex = Vector2()
				
				if neighbor.x == 1:
					vertex.x += neighbor.x * Global.vec.size.window.width 
				
				if neighbor.y == 1:
					vertex.y += neighbor.y * Global.vec.size.window.height 
				
				border.append(vertex)
				
			borders.append(border)
		
		corners.append(borders[0].front())
		corners.append(borders[2].front())
		arr.wasserscheide = []
		
		for fringe in Global.obj.blatt.arr.fringe:
			if fringe.arr.dreieck.size() == 2:
				var input = {}
				input.meer = self
				input.poles = []
				
				for dreieck in fringe.arr.dreieck:
					input.poles.append(dreieck.obj.pole)
				
				var wasserscheide = Classes_1.Wasserscheide.new(input)
				arr.wasserscheide.append(wasserscheide)
			else:
				var punkt = fringe.arr.dreieck.front().obj.pole
				var point = null
				var vertexs = []
				var positions = []
				var neighbor_dreiecks = []
				
				if Global.point_inside_rect(punkt.scene.myself.position, corners):
					var point_on_fringe = Global.nearest_point_on_line_through_another_point(fringe, punkt)
					point = point_on_fringe
					
					for border in borders:
						var lines = [border]
						lines.append([point_on_fringe, fringe.arr.dreieck.front().obj.pole.scene.myself.position])
						var border_intersection = Global.line_line_intersection(lines)
						
						if border_intersection != null:
							var flag = true
							
							for fringe_ in Global.obj.blatt.arr.fringe:
								var line = []
								line.append(fringe_.arr.punkt.front().scene.myself.position)
								line.append(fringe_.arr.punkt.back().scene.myself.position)
								lines = [line]
								line = [punkt, border_intersection]
								var fringe_intersection = Global.line_line_intersection(lines)
								
								if fringe_intersection != null:
									flag = false
									break
							
							if flag:
								vertexs.append(border_intersection)
					
					vertexs.sort_custom(func(a, b): return a.distance_to(point) < b.distance_to(point))
					positions.append(vertexs.front())
				else:
					var unfringed_punkts = []
					unfringed_punkts.append_array(fringe.arr.dreieck.front().arr.punkt )
					
					for ship in fringe.arr.punkt:
						unfringed_punkts.erase(ship)
					
					for ship in fringe.arr.punkt:
						for fringe_ in ship.arr.fringe:
							if fringe_ != fringe and fringe_.arr.punkt.has(unfringed_punkts.front()):
								var dreiecks = []
								dreiecks.append_array(fringe_.arr.dreieck)
								dreiecks.erase(fringe.arr.dreieck.front())
								neighbor_dreiecks.append(dreiecks.front())
						
						vertexs = []
						var line = [punkt.scene.myself.position, neighbor_dreiecks.back().obj.pole.scene.myself.position]
						
						for border in borders:
							var lines = [border]
							lines.append(line)
							var border_intersection = Global.line_line_intersection(lines)
							
							if border_intersection != null:
								vertexs.append(border_intersection)
						
						for _i in range(vertexs.size()-1, -1, -1):
							var vertex = vertexs[_i]
							var min = Vector2()
							min.x = min(line.front().x, line.back().x)
							min.y = min(line.front().y, line.back().y)
							var max = Vector2()
							max.x = max(line.front().x, line.back().x)
							max.y = max(line.front().y, line.back().y)
							var flag = vertex.x >= min.x and vertex.x <= max.x and vertex.y >= min.y and vertex.y <= max.y
							
							if !flag:
								vertexs.erase(vertex)
						
						if vertexs.size() == 1:
							print(vertexs.front())
							positions.append(vertexs.front())
				
				for _i in positions.size():
					var input = {}
					input.type = "pole"
					input.blatt = Global.obj.blatt
					input.position = positions[_i]
					var pole = Classes_0.Punkt.new(input)
					pole.scene.myself.set_color(Color.RED)
					
					if positions.size() == 2:
						pole.scene.myself.set_color(Color.GREEN)
					
					Global.obj.blatt.arr.pole.append(pole)
					pole.flag.border = true
					#print(">",positions[_i])
					
					input = {}
					input.meer = self
					input.poles = [pole]
					
					match positions.size():
						1:
							input.poles.append(fringe.arr.dreieck.front().obj.pole)
						2:
							input.poles.append(neighbor_dreiecks[_i].obj.pole)
					
					var wasserscheide = Classes_1.Wasserscheide.new(input)
					wasserscheide.scene.myself.set_default_color(Color.AZURE)
					arr.wasserscheide.append(wasserscheide)
