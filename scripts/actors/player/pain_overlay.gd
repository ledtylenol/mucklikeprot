
extends ColorRect
var alpha := 0.0
var _color := Vector3(1.0, 0.0, 0.0)
@export var health_component: HealthComponent
@onready var rich_text_label: RichTextLabel = $RichTextLabel
func _process(_delta: float) -> void:
	material.set_shader_parameter("alpha", alpha)
	material.set_shader_parameter("color", _color)
func _on_hurtbox_damage_taken(damage: int, _who_done_it: Hitbox, _effects: Array[EffectBase]) -> void:
	if get_parent().get_parent().dead:
		return
	rich_text_label.text = str("[center][shake rate=50 level=40]%s" % (health_component.health - damage))
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
	if health_component.health - 1 <= 0:
		rich_text_label.text = str("[center][shake rate=50 level=40]DEAD" )
		tween.tween_property($RichTextLabel, "modulate:a", 0.0, 4.0).from(1.0)
		tween.tween_property(self, "alpha", 1.0, 2)
		return
	_color = Vector3(1.0, 0.0, 0.0)
	tween.tween_property($RichTextLabel, "modulate:a", 0.0, 0.7).from(1.0)
	tween.tween_property(self, "alpha", 0.0, 2).from(0.5 * (damage / 3.0))
	tween.tween_property($RichTextLabel, "modulate:a", 0.0, 0.7).from(1.0)


func _on_player_dashed() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
	_color = Vector3(0.0, 0.3, 0.7)
	tween.tween_property(self, "alpha", 0.0, 2).from(0.5)
