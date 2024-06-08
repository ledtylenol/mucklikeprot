extends Button
var tween: Tween


func _process(delta: float) -> void:
	pivot_offset = Vector2(size.x / 2.0, size.y / 2.0)

func _on_mouse_entered() -> void:
	if tween:
		tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 1.0)


func _on_mouse_exited() -> void:
	if tween:
		tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, 1.0)


func _on_button_down() -> void:
	if tween:
		tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 1.0)


func _on_button_up() -> void:
	if tween:
		tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, 1.0)

