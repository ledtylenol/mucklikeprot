extends Resource
class_name PassiveItemBase

signal remove

@export var name: String
@export_multiline var description: String
@export var texture: Texture
@export var model: Mesh
@export var effect: EffectBase
func do_start_effect(_parent: Node3D):
	if effect:
		remove.connect(effect.signal_remove)
func do_remove_effect(_parent: Node3D):
	remove.emit()

