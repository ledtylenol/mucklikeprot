extends EffectBase
class_name Shoe
@export var speed_add: int = 1
func on_add(handler: EffectHandler):
	if "stats" in handler:
		handler.stats.speed += speed_add
func on_remove(handler: EffectHandler):
	if "stats" in handler:
		handler.stats.speed -= speed_add
