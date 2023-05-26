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
		
		for dreieck in arr.dreieck:
			dreieck.arr.punkt.erase(self)
		
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
		arr.punkt = input_.punkts
		dict.wasserscheide = {}
		dict.fringe = {}
		init_scene()
		set_circumcenter()
		
		for punkt in arr.punkt:
			punkt.arr.dreieck.append(self)


	func init_scene() -> void:
		scene.myself = Global.scene.dreieck.instantiate()
		scene.myself.set_parent(self)
		obj.blatt.scene.myself.get_node("Dreieck").add_child(scene.myself)


	func set_circumcenter() -> void:
		var points = []
		
		for punkt in arr.punkt:
			points.append(punkt.scene.myself.position)
		
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
		
		for _i in arr.punkt.size():
			var _j = (_i+1)%arr.punkt.size()
			var a = arr.punkt[_i]
			var b = arr.punkt[_j]
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
		
		for punkt in arr.punkt:
			punkt.arr.dreieck.erase(self)


#грань fringe
class Fringe:
	var arr = {}
	var obj = {}
	var scene = {}


	func _init(input_):
		obj.blatt = input_.blatt
		arr.punkt = input_.punkts
		arr.dreieck = []
		
		for punkt in arr.punkt:
			punkt.arr.fringe.append(self)


	func init_scene() -> void:
		scene.myself = Global.scene.fringe.instantiate()
		scene.myself.set_parent(self)
		obj.blatt.scene.myself.get_node("Fringe").add_child(scene.myself)


	func set_dreiecks() -> void:
		var dreiecks = {}
		
		for punkt in arr.punkt:
			for dreieck in punkt.arr.dreieck:
				if dreiecks.keys().has(dreieck):
					dreiecks[dreieck] += 1
				else:
					dreiecks[dreieck] = 1
		
		for dreieck in dreiecks.keys():
			if dreiecks[dreieck] == 2:
				arr.dreieck.append(dreieck)
			
			if !dreieck.dict.fringe.keys().has(self):
				var punkts = []
				punkts.append_array(dreieck.arr.punkt)
				
				for punkt in arr.punkt:
					punkts.erase(punkt)
				
				dreieck.dict.fringe[self] = punkts.front()


#лист blatt
class Blatt:
	var arr = {}
	var obj = {}
	var scene = {}


	func _init():
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
		var n = 5
		var gap = 0.3
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
				
				for ship in arr.ship:
					if input.position.distance_to(ship.scene.myself.position) < r:
						flag = false
						break
				
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
		input.punkts = []
		
		for _i in range(arr.ship.size()-3, arr.ship.size(), 1):
			input.punkts.append(arr.ship[_i])
		
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
				input.punkts = [ship]
				input.punkts.append_array(edge)
				var dreieck = Classes_0.Dreieck.new(input)
				arr.dreieck.append(dreieck)
			
			for dreieck_ in arr.dreieck:
				dreieck_.scene.myself.update_color()
		else:
			erase_supra_triangle()


	func erase_supra_triangle() -> void:
		for _i in range(arr.ship.size()-1, -1, -1):
			var punkt = arr.ship[_i]
			
			if punkt.flag.temp:
				punkt.become_obsolete()
		
		for _i in range(arr.dreieck.size()-1, -1, -1):
			var dreieck = arr.dreieck[_i]
			
			if dreieck.arr.punkt.size() < 3:
				dreieck.become_obsolete()


	func init_fringes() -> void:
		arr.fringe = []
		var ships = []
		ships.append_array(arr.ship)
		
		while ships.size() > 0:
			var ship = ships.front()
			var punkts = []
			
			for dreieck in ship.arr.dreieck:
				var edges = dreieck.get_adjacent_edges_by_punkt(ship)
				
				for edge in edges:
					edge.erase(ship)
					var punkt = edge.front()
					
					if !punkts.has(punkt) and ships.has(punkt):
						punkts.append(punkt)
			
			for punkt in punkts:
				var flag = true
				
				if !ships.has(punkt):
					flag = false
					break
				
				if flag:
					var input = {}
					input.punkts = [ship,punkt]
					input.blatt = self
					var fringe = Classes_0.Fringe.new(input)
					arr.fringe.append(fringe)
			
			ships.pop_front()
		
		for fringe in arr.fringe:
			fringe.set_dreiecks()
