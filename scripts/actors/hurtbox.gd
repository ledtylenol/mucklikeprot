extends Area3D
class_name Hurtbox

signal damage_taken(damage: int, entity: Hitbox, effects: EffectBase)


func _ready() -> void:
	area_entered.connect(on_area_entered)


func on_area_entered(area: Area3D):
	var hitbox = area as Hitbox
	if not hitbox or hitbox.ignore_list.has(self):
		return
	if not hitbox.pierce:
		hitbox.ignore_list.append(self)
	elif hitbox.despawn_after_hit:
		hitbox.set_deferred("monitorable", false)
	else:
		hitbox.set_deferred("monitorable", false)
		await get_tree().process_frame
		hitbox.set_deferred("monitorable", true)
	damage_taken.emit(hitbox.damage, hitbox, hitbox.effects)

