extends CharacterBody3D
class_name DebugMarker
@onready var start_pos = global_position


func _on_timer_timeout() -> void:
	var rand_vec = Vector3(randf_range(-40, 40),randf_range(-1, 1),randf_range(-40, 40))
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "global_position", start_pos + rand_vec, 1)
