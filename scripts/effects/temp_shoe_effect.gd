extends TemporaryEffect
class_name TempShoeEffect

func on_add(handler: EffectHandler):
	super.on_add(handler)
	if "stats" in handler and handler.stats:
		handler.stats.speed += 10

func on_remove(handler: EffectHandler):
	super.on_remove(handler)
	if "stats" in handler and handler.stats:
		handler.stats.speed -= 10
