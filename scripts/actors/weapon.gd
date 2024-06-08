extends Node3D
class_name Weapon
var stats: PlayerStats
var effects: Array[EffectBase]

var ignore_list: Array[Hurtbox]
var cooldown: float = 1.0
var dt := 0.0

var transform_target: Node3D
const BULLET_TEST = preload("res://scenes/bullet_test.tscn")
func _physics_process(delta: float) -> void:
	dt += delta
	if Input.is_action_pressed("shoot") and dt > cooldown and transform_target:
		dt = 0
		var bullet = BULLET_TEST.instantiate()
		GlobalObserver.spawn_entity_at(bullet, transform_target.global_position, "entity", transform_target.global_basis)
		bullet.hitbox.ignore_list.append_array(ignore_list)
		print("Shot %s" % bullet.global_position)
