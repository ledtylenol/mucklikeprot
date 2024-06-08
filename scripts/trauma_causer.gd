
extends Area3D
class_name TraumaCauser

@export var trauma_count := 0.1

func cause_trauma(_x = null, _y = null):
	var trauma_areas := get_overlapping_areas()
	for area in trauma_areas:
		if "add_trauma" in area:
			area.add_trauma(trauma_count)

