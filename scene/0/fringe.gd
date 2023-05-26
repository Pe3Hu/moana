extends Line2D


var parent = null


func set_parent(parent_) -> void:
	parent = parent_
	set_vertexs()


func set_vertexs() -> void:
	for ship in parent.arr.ship:
		add_point(ship.scene.myself.position)
