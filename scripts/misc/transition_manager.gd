extends CanvasLayer

const dead_scene = preload("res://scenes/dead_scene.tscn")
const alive_scene = preload("res://scenes/main_scene.tscn")
func do_death():
	await get_tree().physics_frame
	get_tree().change_scene_to_packed(dead_scene)

func do_alive():
	get_tree().change_scene_to_packed(alive_scene)
