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
	var vec = {}
	var arr = {}
	var obj = {}
	var word = {}
	var scene = {}


	func _init(input_):
		obj.meer = input_.meer
		obj.fringe = input_.fringe
		arr.pole = input_.poles
		word.type = input_.type
		obj.dreieck = input_.dreieck
		
		if obj.fringe != null:
			obj.fringe.obj.wasserscheide = self
		init_scene()
		set_punkt()
		set_intersection()


	func init_scene() -> void:
		scene.myself = Global.scene.wasserscheide.instantiate()
		scene.myself.set_parent(self)
		obj.meer.scene.myself.get_node("Wasserscheide").add_child(scene.myself)


	func set_punkt() -> void:
		for pole in arr.pole:
			pole.arr.wasserscheide.append(self)


	func set_intersection() -> void:
		if obj.fringe != null:
			var lines = []
			var line = []
			
			for pole in arr.pole:
				line.append(pole.scene.myself.position)
			
			lines.append(line)
			line = []
			
			for ship in obj.fringe.arr.ship:
				line.append(ship.scene.myself.position)
			
			lines.append(line)
			vec.intersection = Global.lines_intersection(lines)
			obj.fringe.vec.intersection = vec.intersection


	func get_border_pole() -> Variant:
		for pole in arr.pole:
			if pole.flag.border:
				return pole
		
		return null


	func get_another_pole(pole_: Classes_0.Punkt) -> Variant:
		var poles = []
		poles.append_array(arr.pole)
		poles.erase(pole_)
		
		if poles.size() == 1:
			return poles.front()
		
		return null


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
		
		set_wasserscheide_by_center_fringes()
		set_wasserscheide_by_two_poles(borders, corners)
		set_pole_projections_on_boundary(borders, corners)
		set_wasserscheide_by_one_pole(borders, corners)
		set_wasserscheide_by_two_poles(borders, corners)
		add_corner_poles(borders)


	func set_wasserscheide_by_center_fringes():
		for fringe in Global.obj.blatt.arr.fringe:
			if fringe.arr.dreieck.size() == 2:
				var input = {}
				input.type = "center"
				input.meer = self
				input.fringe = fringe
				input.dreieck = null
				input.poles = []
				
				for dreieck in fringe.arr.dreieck:
					input.poles.append(dreieck.obj.pole)
				
				var wasserscheide = Classes_1.Wasserscheide.new(input)
				arr.wasserscheide.append(wasserscheide)


	func set_wasserscheide_by_two_poles(borders_: Array, corners_: Array):
		var size = 2
		var poles = []
		
		for dreieck in Global.obj.blatt.arr.dreieck:
			if size == dreieck.obj.pole.arr.wasserscheide.size() and dreieck.obj.pole.arr.wasserscheide.size() > 0:
				poles.append(dreieck.obj.pole)
		
		for pole in poles:
			if Global.point_inside_rect(pole.scene.myself.position, corners_):
				var dreieck = pole.obj.circumcenter
				var neighbor_poles = []
				var ships = []
				ships.append_array(dreieck.arr.ship)
		
				for wasserscheide in pole.arr.wasserscheide:
					var ship = dreieck.dict.fringe[wasserscheide.obj.fringe]
					ships.erase(ship)
					var neighbor_pole = wasserscheide.get_another_pole(pole)
					
					if neighbor_pole != null:
						neighbor_poles.append(neighbor_pole)
				
				if neighbor_poles.size() == 2:
					for ship in ships:
						ship.scene.myself.set_color(Color.YELLOW)
						var fringe = dreieck.get_opposite_fringe_by_punkt(ship)
						var point_on_fringe = Global.nearest_point_on_line_through_another_point(fringe, pole)
						var angles = {}
						angles.pole = []
						angles.border = []
						
						for neighbor_pole in neighbor_poles:
							var vector = neighbor_pole.scene.myself.position - pole.scene.myself.position
							var angle = vector.angle()
							angle *= 180/PI 
							angles.pole.append(angle)
						
						for angle in angles.pole:
							angles.min = min(angles.pole.front(), angle)
							angles.max = max(angles.pole.front(), angle)
						
						angles.coverage = abs(angles.max-angles.min)
						angles.sign = sign(angles.min) == sign(angles.max)
						
						for border in borders_:
							var lines = [border]
							lines.append([point_on_fringe, dreieck.obj.pole.scene.myself.position])
							var border_intersection = Global.lines_intersection(lines)
							
							if border_intersection != null and Global.point_inside_rect(border_intersection, corners_):
								var vector = border_intersection - pole.scene.myself.position
								var angle = vector.angle()
								angle *= 180/PI 
								
								var inside = angles.min <= angle and angles.max >= angle
								var flag = true
								
								if angles.sign:
									flag = !inside
								elif angles.coverage < 180:
									flag = !inside
								else:
									flag = inside
								
								if flag:
									angles.border.append(border_intersection)
						
						if angles.border.size() > 0:
							var input = {}
							input.type = "pole"
							input.blatt = Global.obj.blatt
							input.position = angles.border.front()
							var pole_ = Classes_0.Punkt.new(input)
							pole_.scene.myself.set_color(Color.RED)
							Global.obj.blatt.arr.pole.append(pole_)
							pole_.flag.border = true
							
							input = {}
							input.type = "corner"
							input.meer = self
							input.dreieck = dreieck
							input.fringe = fringe
							input.poles = [pole]
							input.poles.append(pole_)
							var wasserscheide = Classes_1.Wasserscheide.new(input)
							wasserscheide.scene.myself.set_default_color(Color.AZURE)
							arr.wasserscheide.append(wasserscheide)
						if angles.border.size() != 1:
							print("!error! wasserscheide borders != 1 ")
							dreieck.obj.pole.scene.myself.set_color(Color.ORANGE)
				else:
					print("!error! neighbor_poles size != 2")
			else:
				add_pole_projection_on_boundary(pole, borders_)


	func set_wasserscheide_by_one_pole(borders_: Array, corners_: Array):
		var size = 1
		var poles = []
		
		for dreieck in Global.obj.blatt.arr.dreieck:
			if size == dreieck.obj.pole.arr.wasserscheide.size() and dreieck.obj.pole.arr.wasserscheide.size() > 0:
				poles.append(dreieck.obj.pole)
		
		for pole in poles:
			if Global.point_inside_rect(pole.scene.myself.position, corners_):
				pole.scene.myself.set_color(Color.BLUE)
				var wasserscheide = pole.arr.wasserscheide.front()
				
				for ship in wasserscheide.obj.fringe.arr.ship:
					var border_pole = null
					var fringes = [wasserscheide.obj.fringe]
					
					for fringe in ship.arr.fringe:
						if fringe.obj.wasserscheide != null:
							var border_pole_ = fringe.obj.wasserscheide.get_border_pole()
							
							if border_pole_ != null:
								fringes.append(fringe)
								border_pole = border_pole_
				
					if border_pole != null:
						var opposite_fringe = []
						
						for fringe in pole.obj.circumcenter.dict.fringe.keys():
							var punkt = pole.obj.circumcenter.dict.fringe[fringe]
							
							if fringe.arr.ship.has(ship) and wasserscheide.obj.fringe != fringe:
								opposite_fringe.append(fringe)
						
						if opposite_fringe.size() == 1:
							opposite_fringe = opposite_fringe.front()
						else:
							print("!error! opposite_fringe size != 1 in two func")
						
						var point_of_reference = pole.obj.circumcenter.dict.fringe[wasserscheide.obj.fringe].scene.myself.position
						#pole.obj.circumcenter.dict.fringe[wasserscheide.obj.fringe].scene.myself.position#fringes.front().vec.intersection
						var point_on_fringe = Global.nearest_point_on_line_through_another_point(opposite_fringe, pole)
						
						var datas = []
						
						for border in borders_:
							var lines = [border]
							lines.append([point_on_fringe, pole.scene.myself.position])
							var border_intersection = Global.lines_intersection(lines)
							
							if border_intersection != null and Global.point_inside_rect(border_intersection, corners_):
								var border_positions = [border_pole.scene.myself.position, border_intersection]
								var angles = {}
								angles.pole = []
								angles.border = []
								
								for border_position in border_positions:
									var vector = border_position - point_of_reference
									var angle = vector.angle()
									angle *= 180/PI 
									angles.pole.append(angle)
								
								for angle in angles.pole:
									angles.min = min(angles.pole.front(), angle)
									angles.max = max(angles.pole.front(), angle)
								
								angles.coverage = abs(angles.max-angles.min)
								angles.sign = sign(angles.min) == sign(angles.max)
								var vector = pole.scene.myself.position - point_of_reference
								var angle = vector.angle()
								angle *= 180/PI 
								
								var inside = angles.min <= angle and angles.max >= angle
								var flag = true
								
								if angles.sign:
									flag = !inside
								elif angles.coverage < 180:
									flag = !inside
								else:
									flag = inside
								
								if flag:
									var data = {}
									data.coverage = angles.coverage
									data.position = border_intersection
									datas.append(data)
									angles.border.append(border_intersection)
						
						datas.sort_custom(func(a, b): return a.coverage < b.coverage)
					
						if datas.size() > 0:
							var input = {}
							input.type = "pole"
							input.blatt = Global.obj.blatt
							input.position = datas.front().position
							var pole_ = Classes_0.Punkt.new(input)
							pole_.scene.myself.set_color(Color.YELLOW)
							Global.obj.blatt.arr.pole.append(pole_)
							pole_.flag.border = true
							
							input = {}
							input.type = "corner"
							input.meer = self
							input.dreieck = pole.obj.circumcenter
							input.fringe = opposite_fringe
							input.poles = [pole]
							input.poles.append(pole_)
							var wasserscheide_ = Classes_1.Wasserscheide.new(input)
							wasserscheide_.scene.myself.set_default_color(Color.AZURE)
							arr.wasserscheide.append(wasserscheide_)
					else:
						print("!error! wasserscheide borders < 0 in two func")
						pass
					
					ship.scene.myself.set_color(Color.GREEN)
			else:
				add_pole_projection_on_boundary(pole, borders_)


	func add_pole_projection_on_boundary(pole_: Classes_0.Punkt, borders_: Array) -> void:
		for wasserscheide in pole_.arr.wasserscheide:
			var line = []
			
			for punkt in wasserscheide.arr.pole:
				line.append(punkt.scene.myself.position)
			
			for border in borders_:
				var lines = [border,line]
				var border_intersection = Global.lines_intersection(lines)
				
				if border_intersection != null and Global.point_inside_rect(border_intersection, line):
					var input = {}
					input.type = "pole"
					input.blatt = Global.obj.blatt
					input.position = border_intersection
					var pole = Classes_0.Punkt.new(input)
					pole.scene.myself.set_color(Color.PURPLE)
					Global.obj.blatt.arr.pole.append(pole)
					pole.flag.border = true
					wasserscheide.arr.pole.append(pole)
		
		pole_.become_obsolete()


	func set_pole_projections_on_boundary(borders_: Array, corners_: Array) -> void:
		for pole in Global.obj.blatt.arr.pole:
			if !Global.point_inside_rect(pole.scene.myself.position, corners_):
				add_pole_projection_on_boundary(pole, borders_)


	func add_corner_poles(borders_: Array) -> void:
		var borders = {}
		for border_ in borders_:
			borders[border_] = []
		
		for pole in Global.obj.blatt.arr.pole:
			for border_ in borders.keys():
				if pole.flag.border:
					if Global.point_inside_rect(pole.scene.myself.position, border_):
						borders[border_].append(pole)
		
		for border in borders_:
			var input = {}
			input.type = "pole"
			input.blatt = Global.obj.blatt
			input.position = border.front()
			var pole = Classes_0.Punkt.new(input)
			Global.obj.blatt.arr.pole.append(pole)
			pole.flag.border = true
			
			for border_ in borders:
				if border_.has(border.front()):
					borders[border_].append(pole)
		
		for border in borders:
			if border.front().x == border.back().x:
				borders[border].sort_custom(func(a, b): return a.scene.myself.position.y < b.scene.myself.position.y)
			if border.front().y == border.back().y:
				borders[border].sort_custom(func(a, b): return a.scene.myself.position.x < b.scene.myself.position.x)
			
			for _i in borders[border].size()-1:
				var input = {}
				input.type = "border"
				input.meer = self
				input.dreieck = null
				input.fringe = null
				input.poles = []
				var pole =  borders[border][_i]
				input.poles.append(pole)
				pole =  borders[border][_i+1]
				input.poles.append(pole)
				var wasserscheide = Classes_1.Wasserscheide.new(input)
				wasserscheide.scene.myself.set_default_color(Color.YELLOW)
				arr.wasserscheide.append(wasserscheide)
		
		var n = 0
		
		for wasserscheide in arr.wasserscheide:
			if wasserscheide.word.type == "border":
				n += 1
		
		print("border wasserscheides: ", n)
