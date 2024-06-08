extends EffectBase
class_name WeakShield
const shield_scene = preload("res://scenes/shield.tscn")
var scene: Node3D
func on_add(parent: Node3D):
	scene = shield_scene.instantiate()
	parent.add_child(scene)
func on_remove(_parent: Node3D):
	scene.queue_free()
