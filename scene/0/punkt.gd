extends Polygon2D


var parent = null


func set_parent(parent_) -> void:
	parent = parent_
	position = parent_.vec.position
	set_vertexs()
	update_color()


func set_vertexs() -> void:
	var a = 4
	var vertexs = []
	
	for neighbor in Global.dict.neighbor.linear2:
		var vertex = neighbor*a
		vertexs.append(vertex)
	
	set_polygon(vertexs)


func update_color() -> void:
	var color_ = null
	
	match parent.word.type:
		"pole":
			color_ = Color.BLACK
		"ship":
			color_ = Color.WHITE
	
	set_color(color_)

