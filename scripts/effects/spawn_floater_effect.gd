extends OneOffEffect
class_name SpawnFloaterEffect

func on_add(handler: EffectHandler):
	var floater = load("res://scenes/floater.tscn").instantiate()
	GlobalObserver.spawn_entity_at(floater, handler.parent.global_position, "main")
