extends Node


#точка punkt
class Punkt:
	var num = {}
	var vec = {}
	var arr = {}
	var obj = {}
	var word = {}
	var dict = {}
	var flag = {}
	var scene = {}


	func _init(input_):
		num.index = Global.num.index.punkt
		Global.num.index.punkt += 1
		word.type = input_.type
		vec.position = input_.position
		obj.blatt = input_.blatt
		obj.circumcenter = null
		flag.temp = false
		flag.border = false
		arr.dreieck = []
		arr.fringe = []
		arr.wasserscheide = []
		#dict.wasserscheide = {}
		init_scene()


	func init_scene() -> void:
		scene.myself = Global.scene.punkt.instantiate()
		scene.myself.set_parent(self)
		obj.blatt.scene.myself.get_node("Punkt").add_child(scene.myself)


	func become_obsolete() -> void:
		Global.num.index.punkt -= 1
		
		for punkt in obj.blatt.arr[word.type]:
			if punkt.num.index > num.index:
				punkt.num.index -= 1
		
		match word.type:
			"ship":
				for dreieck in arr.dreieck:
					dreieck.arr.ship.erase(self)
				
				for fringe in arr.fringe:
					fringe.arr.ship.erase(self)
			"pole":
				for wasserscheide in arr.wasserscheide:
					wasserscheide.arr.pole.erase(self)
					wasserscheide.scene.myself.set_vertexs()
		
		obj.blatt.arr[word.type].erase(self)
		scene.myself.queue_free()


#треугольник dreieck
class Dreieck:
	var num = {}
	var vec = {}
	var arr = {}
	var obj = {}
	var dict = {}
	var scene = {}


	func _init(input_):
		num.index = Global.num.index.dreieck
		Global.num.index.dreieck += 1
		obj.blatt = input_.blatt
		arr.ship = input_.ships
		dict.wasserscheide = {}
		dict.fringe = {}
		init_scene()
		set_circumcenter()
		
		for ship in arr.ship:
			ship.arr.dreieck.append(self)


	func init_scene() -> void:
		scene.myself = Global.scene.dreieck.instantiate()
		scene.myself.set_parent(self)
		obj.blatt.scene.myself.get_node("Dreieck").add_child(scene.myself)


	func set_circumcenter() -> void:
		var points = []
		
		for ship in arr.ship:
			points.append(ship.scene.myself.position)
		
		vec.circumcenter = Global.get_circumcenter(points)
		num.radius = vec.circumcenter.distance_to(points.front())
		
		var input = {}
		input.type = "pole"
		input.blatt = obj.blatt
		input.position = vec.circumcenter
		obj.pole = Classes_0.Punkt.new(input)
		obj.blatt.arr.pole.append(obj.pole)
		obj.pole.obj.circumcenter = self


	func get_edges() -> Array:
		var edges = []
		
		for _i in arr.ship.size():
			var _j = (_i+1)%arr.ship.size()
			var a = arr.ship[_i]
			var b = arr.ship[_j]
			var edge = [a,b]
			edge.sort_custom(func(a, b): return a.num.index < b.num.index)
			edges.append(edge)
		
		return edges


	func get_adjacent_edges_by_punkt(punkt_: Punkt) -> Array:
		var edges = get_edges()
		
		for _i in range(edges.size()-1, -1, -1):
			var edge = edges[_i]
			
			if !edge.has(punkt_):
				edges.erase(edge)
		
		return edges


	func get_opposite_edge_by_punkt(punkt_: Punkt) -> Variant:
		var all_edges = get_edges()
		var adjacent_edges = get_adjacent_edges_by_punkt(punkt_)
		
		for edge in adjacent_edges:
			all_edges.erase(edge)
		
		#print(all_edges.size(), all_edges.front(), adjacent_edges.size())
		if all_edges.size() == 1:
			return all_edges.front()
		else:
			return null


	func get_opposite_fringe_by_punkt(punkt_: Punkt) -> Variant:
		for fringe in dict.fringe.keys():
			if dict.fringe[fringe] == punkt_:
				return fringe
		
		return null


	func become_obsolete() -> void:
		Global.num.index.dreieck -= 1
		
		for dreieck in obj.blatt.arr.dreieck:
			if dreieck.num.index > num.index:
				dreieck.num.index -= 1
		
		obj.blatt.arr.dreieck.erase(self)
		scene.myself.queue_free()
		obj.blatt.arr.pole.erase(obj.pole)
		obj.pole.scene.myself.queue_free()
		
		for ship in arr.ship:
			ship.arr.dreieck.erase(self)


#грань fringe
class Fringe:
	var arr = {}
	var obj = {}
	var vec = {}
	var scene = {}


	func _init(input_):
		obj.blatt = input_.blatt
		arr.ship = input_.ships
		arr.dreieck = input_.dreiecks
		vec.intersection = null
		init_scene()
		set_punkts()


	func init_scene() -> void:
		scene.myself = Global.scene.fringe.instantiate()
		scene.myself.set_parent(self)
		obj.blatt.scene.myself.get_node("Fringe").add_child(scene.myself)


	func set_punkts() -> void:
		for ship in arr.ship:
			ship.arr.fringe.append(self)
		
		for dreieck in arr.dreieck:
			for ship in dreieck.arr.ship:
				var edge = dreieck.get_opposite_edge_by_punkt(ship)
				var flag = true
				
				for ship_ in arr.ship:
					flag = edge.has(ship_) and flag
				
				if flag:
					dreieck.dict.fringe[self] = ship
					break


	func common_punkt_with_fringe(fringe_: Fringe) -> Variant:
		var punkts = {}
		var fringes = [self, fringe_]
		
		for fringe in fringes:
			for ship in fringe.arr.ship:
				if punkts.keys().has(ship):
					punkts[ship] += 1
				else:
					punkts[ship] = 1
		
		for punkt in punkts.keys():
			if punkts[punkt] == 2:
				return punkt
		
		return null


#лист blatt
class Blatt:
	var num = {}
	var arr = {}
	var obj = {}
	var scene = {}


	func _init():
		num.dreieck = 0
		num.ship = -1
		init_scene()
		init_ships()
		init_dreiecks()
		init_fringes()


	func init_scene() -> void:
		scene.myself = Global.scene.blatt.instantiate()
		Global.node.game.get_node("Layer0").add_child(scene.myself)


	func init_ships() -> void:
		arr.ship = []
		arr.pole = []
		var w = Global.vec.size.window.width
		var h = Global.vec.size.window.height
		var n = 16
		var gap = 0.05
		var r = 150
		var input = {}
		input.type = "ship"
		input.blatt = self
		
		for _i in n:
			var flag = false
			
			while !flag:
				flag = true
				Global.rng.randomize()
				var x = int(Global.rng.randf_range(gap, (1-gap)) * w)
				Global.rng.randomize()
				var y = int(Global.rng.randf_range(gap, (1-gap)) * h)
				input.position = Vector2(x,y)
				
				#for ship in arr.ship:
				#	if input.position.distance_to(ship.scene.myself.position) < r:
				#		flag = false
				#		break
				
			var punkt = Classes_0.Punkt.new(input)
			arr.ship.append(punkt)
		
		input.position = Vector2()
		var punkt = Classes_0.Punkt.new(input)
		punkt.flag.temp = true
		arr.ship.append(punkt)
		
		input.position = Vector2(0, h * 2)
		punkt = Classes_0.Punkt.new(input)
		punkt.flag.temp = true
		arr.ship.append(punkt)
		
		input.position = Vector2(w * 2, 0)
		punkt = Classes_0.Punkt.new(input)
		punkt.flag.temp = true
		arr.ship.append(punkt)


	#bowyer watson algorithm
	#godot has triangulate_delaunay func 
	func init_dreiecks() -> void:
		arr.dreieck = []
		var input = {}
		input.blatt = self
		input.ships = []
		
		for _i in range(arr.ship.size()-3, arr.ship.size(), 1):
			input.ships.append(arr.ship[_i])
		
		var dreieck = Classes_0.Dreieck.new(input)
		arr.dreieck.append(dreieck)
		
		for _i in arr.ship.size() - 2:
			next_dreieck()


	func next_dreieck() -> void:
		var ship = null
		
		for punkt in arr.ship:
			if punkt.arr.dreieck.size() == 0:
				ship = punkt
				break
		
		if ship != null:
			var dreiecks = {}
			dreiecks.obsolete = []
			
			for dreieck_ in arr.dreieck:
				var dist = dreieck_.vec.circumcenter.distance_to(ship.scene.myself.position)
				
				if dist < dreieck_.num.radius:
					dreiecks.obsolete.append(dreieck_)
			
			var edges = []
			
			for dreieck_ in dreiecks.obsolete:
				dreieck_.become_obsolete()
				
				for edge in dreieck_.get_edges():
					if edges.has(edge):
						edges.erase(edge)
					else:
						edges.append(edge)
 
			for edge in edges:
				var input = {}
				input.blatt = self
				input.punkts = []
				input.ships = [ship]
				input.ships.append_array(edge)
				var dreieck = Classes_0.Dreieck.new(input)
				arr.dreieck.append(dreieck)
			
			for dreieck_ in arr.dreieck:
				dreieck_.scene.myself.update_color()
		else:
			erase_supra_triangle()


	func erase_supra_triangle() -> void:
		for _i in range(arr.ship.size()-1, -1, -1):
			var ship = arr.ship[_i]
			
			if ship.flag.temp:
				ship.become_obsolete()
		
		for _i in range(arr.dreieck.size()-1, -1, -1):
			var dreieck = arr.dreieck[_i]
			
			if dreieck.arr.ship.size() < 3:
				dreieck.become_obsolete()


	func init_fringes() -> void:
		arr.fringe = []
		var ships = []
		ships.append_array(arr.ship)
		var hashes = []
		var edges = {}
		
		for dreieck in arr.dreieck:
			for ship in dreieck.arr.ship:
				var edge = dreieck.get_opposite_edge_by_punkt(ship)
				var hash = edge.hash()
				
				if !hashes.has(hash):
					edges[edge] = [dreieck]
					hashes.append(hash)
				else:
					edges[edge].append(dreieck)
		
		for edge in edges:
			var input = {}
			input.ships = edge
			input.dreiecks = edges[edge]
			input.blatt = self
			var fringe = Classes_0.Fringe.new(input)
			arr.fringe.append(fringe)
		
		#for fringe in arr.fringe:
		#	fringe.set_dreiecks()


	func next_pair_ship_and_fringe() -> void:
		var dreieck = arr.dreieck[num.dreieck]
		var ship = dreieck.arr.punkt[num.ship]
		var fringe = dreieck.get_opposite_fringe_by_punkt(ship)
		ship.scene.myself.visible = false
		fringe.scene.myself.visible = false
		dreieck.scene.myself.update_color()
		
		num.ship += 1
		
		if num.ship >= dreieck.arr.punkt.size():
			num.ship = 0
			num.dreieck += 1
			
			if num.dreieck >= arr.dreieck.size():
				num.dreieck = 0
		
		dreieck = arr.dreieck[num.dreieck]
		ship = dreieck.arr.punkt[num.ship]
		fringe = dreieck.get_opposite_fringe_by_punkt(ship)
		ship.scene.myself.visible = true
		fringe.scene.myself.visible = true
		dreieck.scene.myself.set_color(Color.BLACK)


	func next_pair_ship_and_dreieck() -> void:
		var dreieck = arr.dreieck[num.dreieck]
		dreieck.scene.myself.update_color()
		
		for ship in dreieck.arr.punkt:
			ship.scene.myself.visible = false
		
		num.dreieck += 1
		
		if num.dreieck >= arr.dreieck.size():
			num.dreieck = 0
		
		dreieck = arr.dreieck[num.dreieck]
		dreieck.scene.myself.set_color(Color.BLACK)
		
		for ship in dreieck.arr.punkt:
			ship.scene.myself.visible = true
