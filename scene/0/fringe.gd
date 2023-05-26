extends Line2D


var parent = null


func set_parent(parent_) -> void:
	parent = parent_
	set_vertexs()


func set_vertexs() -> void:
	for punkt in parent.arr.punkt:
		add_point(punkt.scene.myself.position)
