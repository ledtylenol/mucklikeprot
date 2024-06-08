extends EffectBase

class_name AcceleratorEffect

@export var speed_mult: float = 2.0
func on_add(handler: EffectHandler):
	if "stats" in handler.parent:
		handler.stats.speed_mul += speed_mult
func on_remove(handler: EffectHandler):
	if "stats" in handler.parent:
		handler.stats.speed_mul -= speed_mult
