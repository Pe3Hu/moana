extends Line2D


var parent = null


func set_parent(parent_) -> void:
	parent = parent_
	set_vertexs()
	update_color()


func set_vertexs() -> void:
	points = []
	
	for pole in parent.arr.pole:
		add_point(pole.scene.myself.position)


func update_color() -> void:
	var color_ = Color.BLACK
	set_default_color(color_)
