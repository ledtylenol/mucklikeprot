
extends TraumaCauser
@onready var child = get_child(0)
func cause_trauma(_x=null, _y=null):
	var trauma_areas := get_overlapping_areas()
	for area in trauma_areas:
		if "add_trauma" in area:
			area.trauma = trauma_count

func _process(_delta: float) -> void:
	if get_overlapping_areas():
		trauma_count = ease_out_quad(1.0-get_overlapping_areas()[0].global_position.distance_to(self.global_position)/child.shape.radius)
	cause_trauma(0, 0)

func ease_out_quad(t):
	return 1.0 - (1.0 - t) * (1.0 - t)
