extends Resource
class_name EffectBase

signal remove
func execute(_handler: EffectHandler, _delta: float):
	pass
func on_add(_handler: EffectHandler):
	pass
func on_remove(_handler: EffectHandler):
	pass

func signal_remove():
	remove.emit(self)
