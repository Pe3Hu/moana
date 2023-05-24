extends Node


func _ready() -> void:
	Global.obj.blatt = Classes_0.Blatt.new()
	Global.obj.meer = Classes_1.Meer.new()
	#datas.sort_custom(func(a, b): return a.value < b.value) 012


func _input(event) -> void:
	if event is InputEventKey:
		match event.keycode:
			KEY_SPACE:
				if event.is_pressed() && !event.is_echo():
					Global.obj.blatt.next_dreieck()


func _process(delta_) -> void:
	$FPS.text = str(Engine.get_frames_per_second())
