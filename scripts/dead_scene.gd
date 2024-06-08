extends CanvasLayer

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_anything_pressed():
		TransitionManager.do_alive()
