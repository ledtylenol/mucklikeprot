extends Node

func stop(scale, duration):
	Engine.time_scale = scale
	await get_tree().create_timer(scale * duration).timeout
	Engine.time_scale = 1.0


