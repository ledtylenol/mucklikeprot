extends Node3D
class_name WeaponHandler
@export var starting_weapon: Weapon
@export var hurtbox: Hurtbox
@export var target: Node3D
var effects: Array[EffectBase]
var weapons: Array[Weapon]
var current_weapon: Weapon

func _ready() -> void:
	if starting_weapon:
		push_weapon(starting_weapon)
		switch_weapon(weapons.find(starting_weapon))

func switch_weapon(idx: int) -> void:
	if idx > weapons.size():
		print("idx out of bounds lol")
		return
	var weapon = weapons[idx]
	weapon.effects = effects.duplicate(true)
	weapon.ignore_list.append(hurtbox)
	weapon.transform_target = target
	if current_weapon:
		current_weapon.owner = null
	current_weapon = weapon
	current_weapon.owner = self
func push_weapon(weapon: Weapon) -> void:
	weapons.append(weapon)
