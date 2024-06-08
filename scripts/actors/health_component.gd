extends Node
class_name HealthComponent

signal health_changed(value)
signal max_health_changed(value)

signal dead

@export var max_health: int = 1:
	set(value):
		max_health = value
		health = clampi(health, 0, max_health)
		max_health_changed.emit(value)

var health: int = max_health:
	set(value):
		health = clampi(value, 0, max_health)
		health_changed.emit(value)
		if health <= 0:
			dead.emit()

@export_category("Hurtbox")

@export var invuln_time: float = 0.2
@export var hurtbox: Hurtbox
var current_invuln_time: float = 0.0

var is_dead := false

func _ready() -> void:
	health = max_health
	if hurtbox:
		hurtbox.damage_taken.connect(on_damage_taken)
		


func on_damage_taken(damage: int, _hitbox: Hitbox, _effects: Array[EffectBase]) -> void:
	if current_invuln_time >= 0.001:
		return
	
	health -= damage
