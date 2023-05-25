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
	var word = {}
	var scene = {}


	func _init(input_):
		obj.meer = input_.meer
		obj.fringe = input_.fringe
		arr.pole = input_.poles
		word.type = input_.type
		init_scene()
		
		for dreieck in obj.fringe.arr.dreieck:
#			for punkt in dreieck.arr.punkt:
#				if !obj.fringe.arr.punkt.has(punkt):
			var punkt = null
			
			match word.type:
				"center":
					punkt = dreieck.dict.fringe[obj.fringe]
				"corner":
					for punkt_ in obj.fringe.arr.punkt:
						if !dreieck.dict.wasserscheide.keys().has(punkt_):
							punkt = punkt_
							break
			
			if punkt != null:
				dreieck.dict.wasserscheide[punkt] = self
				#punkt.dict.wasserscheide[obj.fringe] = self
				punkt.scene.myself.set_color(Color.BLUE)
				#print(punkt)
				#print("___")
			else:
				print("wasserscheide error")


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
				input.type = "center"
				input.meer = self
				input.fringe = fringe
				input.poles = []
				
				for dreieck in fringe.arr.dreieck:
					input.poles.append(dreieck.obj.pole)
				
				var wasserscheide = Classes_1.Wasserscheide.new(input)
				arr.wasserscheide.append(wasserscheide)
		
		for fringe in Global.obj.blatt.arr.fringe:
			if fringe.arr.dreieck.size() == 1:
				var dreieck = fringe.arr.dreieck.front()
				
				for punkt in fringe.arr.punkt:
					if dreieck.dict.wasserscheide.keys().has(punkt):
						var neighbor_punkt = []
						neighbor_punkt.append_array(fringe.arr.punkt)
						neighbor_punkt.erase(punkt)
						neighbor_punkt = neighbor_punkt.front()
						
						if !dreieck.dict.wasserscheide.keys().has(neighbor_punkt):
							var point_on_fringe = Global.nearest_point_on_line_through_another_point(fringe, dreieck.obj.pole)
							
							for border in borders:
								var lines = [border]
								lines.append([point_on_fringe, dreieck.obj.pole.scene.myself.position])
								var border_intersection = Global.line_line_intersection(lines)
								
								if border_intersection != null and Global.point_inside_rect(border_intersection, corners):
									var points = [border_intersection]
									
									for pole in dreieck.dict.wasserscheide[punkt].arr.pole:
										points.append(pole.scene.myself.position)
									
									var circumcenter = Global.get_circumcenter(points)
									var r = circumcenter.distance_to(points.front())
									var d = circumcenter.distance_to(neighbor_punkt.scene.myself.position)
									
									if d < r:
										var input = {}
										input.type = "pole"
										input.blatt = Global.obj.blatt
										input.position = border_intersection
										var pole = Classes_0.Punkt.new(input)
										pole.scene.myself.set_color(Color.RED)
										Global.obj.blatt.arr.pole.append(pole)
										pole.flag.border = true
										
										input = {}
										input.type = "corner"
										input.meer = self
										input.fringe = fringe
										input.poles = [pole]
										input.poles.append(dreieck.obj.pole)
										var wasserscheide = Classes_1.Wasserscheide.new(input)
										wasserscheide.scene.myself.set_default_color(Color.AZURE)
										arr.wasserscheide.append(wasserscheide)
			
		for _i in range(arr.wasserscheide.size()-1, -1, -1):
			var wasserscheide = arr.wasserscheide[_i]
			var poles = []
			
			for pole in wasserscheide.arr.pole:
				if Global.point_inside_rect(pole.scene.myself.position, corners):
					poles.append(pole)
			
			match poles.size():
				2:
					#arr.wasserscheide.erase(wasserscheide)
					pass
				1:
					pass 
			
#				var unfringed_punkts = []
#				unfringed_punkts.append_array(dreieck.arr.punkt )
#
#				for ship in fringe.arr.punkt:
#					unfringed_punkts.erase(ship)
#
#				for ship in fringe.arr.punkt:
#					for fringe_ in ship.arr.fringe:
#						if fringe_ != fringe and fringe_.arr.punkt.has(unfringed_punkts.front()):
#							var dreiecks = []
#							dreiecks.append_array(fringe_.arr.dreieck)
#							dreiecks.erase(dreieck)
#							neighbor_dreiecks.append(dreiecks.front())
#
#					vertexs = []
#					var line = [punkt.scene.myself.position, neighbor_dreiecks.back().obj.pole.scene.myself.position]
#
#					for border in borders:
#						var lines = [border]
#						lines.append(line)
#						var border_intersection = Global.line_line_intersection(lines)
#
#						if border_intersection != null:
#							vertexs.append(border_intersection)
#
#					for _i in range(vertexs.size()-1, -1, -1):
#						var vertex = vertexs[_i]
#						var min = Vector2()
#						min.x = min(line.front().x, line.back().x)
#						min.y = min(line.front().y, line.back().y)
#						var max = Vector2()
#						max.x = max(line.front().x, line.back().x)
#						max.y = max(line.front().y, line.back().y)
#						var flag = vertex.x >= min.x and vertex.x <= max.x and vertex.y >= min.y and vertex.y <= max.y
#
#						if !flag:
#							vertexs.erase(vertex)
#
#					if vertexs.size() == 1:
#						positions.append(vertexs.front())
