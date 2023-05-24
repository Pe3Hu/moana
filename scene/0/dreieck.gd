extends Polygon2D


var parent = null


func set_parent(parent_) -> void:
	parent = parent_
	set_vertexs()
	update_color()


func update_color() -> void:
	var max_h = 360.0
	var size = null
	
	var h = float(parent.num.index)/Global.num.index.dreieck
	var s = 0.75
	var v = 1
	var color_ = Color.from_hsv(h,s,v)
	set_color(color_)


func set_vertexs() -> void:
	var vertexs = []
	
	for punkt in parent.arr.punkt:
		var vertex = punkt.scene.myself.position
		vertexs.append(vertex)
	
	set_polygon(vertexs)
