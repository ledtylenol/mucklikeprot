extends Area3D
class_name Hitbox
var ignore_list: Array[Hurtbox] = []
@export var pierce: bool = true
@export var damage: int = 1
@export var despawn_after_hit: bool = true
@export var effects: Array[EffectBase] = []
