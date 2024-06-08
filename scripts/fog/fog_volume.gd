extends FogVolume
@export var duration := 1.0

var time := 0.0

func _process(delta: float) -> void:
	time += delta
	material.set_shader_parameter("time", time / duration)
	
	if time > duration:
		queue_free()
