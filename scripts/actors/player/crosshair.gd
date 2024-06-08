extends Node3D
class_name CrossHair

@onready var time_active := 0.0


func _process(delta: float) -> void:
	var idx = 0
	if get_children()[0].modulate.a:
		time_active += delta
	for child in get_children():
		child.modulate.r = sin(time_active + 3.1 * idx) ** 2
		child.modulate.g = cos(time_active + 1.2 * idx) ** 3
		child.modulate.b = sin(-time_active + 2.2 * idx) ** 4
		idx += 1
