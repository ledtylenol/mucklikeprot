extends EffectBase
class_name TemporaryEffect

@export var duration: float = 1.0
var item: PassiveItemBase
var current_duration: float = duration
var active := true
signal expired

func on_add(_parent):
	current_duration = duration
func execute(_handler: EffectHandler, delta: float):
	if not active:
		return
	current_duration -= delta
	if current_duration <= 0.0:
		expired.emit(self)
