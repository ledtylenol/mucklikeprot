extends Node
class_name EffectHandler

var effects: Array[EffectBase] = []


@export var hurtbox: Hurtbox
@export var parent: CharacterBody3D
@export var weapon_handler: WeaponHandler
@export var health_component: HealthComponent

var stats: PlayerStats
func _ready() -> void:
	if hurtbox:
		hurtbox.damage_taken.connect(on_damage_taken)
	if parent:
		await get_tree().process_frame
		if parent.stats:
			stats = parent.stats

func _process(delta: float) -> void:
	for effect in effects:
		effect.execute(self, delta)

func on_damage_taken(_damage: int, _hitbox: Hitbox, hit_effects: Array[EffectBase]):
	for effect in hit_effects:
		push_effect(effect.duplicate())


func push_effect(effect: EffectBase):
	effects.push_back(effect)
	effect.on_add(self)
	effect.remove.connect(remove_effect)
	if "expired" in effect:
		effect.expired.connect(on_expire)
	if effect is OneOffEffect:
		remove_effect(effect)
func remove_effect(effect: EffectBase):
	effects.erase(effect)
	effect.on_remove(self)

func on_expire(effect: EffectBase):
	remove_effect(effect)
