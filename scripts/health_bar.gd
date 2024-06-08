
extends ProgressBar

@export var health_component: HealthComponent
@onready var label := $RichTextLabel

@export var intensity := 2
var tween2: Tween
func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	max_value = health_component.max_health * 100
	$"../HealthBar2".max_value = health_component.max_health * 100

func _on_health_component_health_changed(new_health: int) -> void:
	var v := maxf(inverse_lerp(health_component.max_health, 0, new_health), 0.3)
	print("%s %s %s" % [new_health, health_component.max_health, intensity])
	label.text = "[center][bounce wave=3][shake level=%s]health: %s" % [int(5 - 5*1.0/(new_health/health_component.max_health))*intensity, new_health]
	if is_equal_approx(v, 0.3):
		label.animation_time = 1.0
	else:
		label.animation_time = v
	label.length = 2 * (5-(new_health/health_component.max_health)) + 1
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
	tween.tween_property(self, "value", new_health * 100, 1.5)

	tween.set_trans(Tween.TRANS_EXPO).tween_property($"../HealthBar2", "value", new_health * 100, 0.5)
	if tween2:
		tween2.stop()
	tween2 = get_tree().create_tween()
	tween2.tween_callback(label.fade_in)
	if is_zero_approx(v):
		tween2.tween_callback(label.fade_out).set_delay(label.animation_time + 0.1)
	else:
		tween2.tween_callback(label.fade_out).set_delay(label.animation_time*2)
