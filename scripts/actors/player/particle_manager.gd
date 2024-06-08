
extends Node3D
@export var jump_particles: PackedScene
@export var fall_particles: PackedScene
@onready var parent: Player = $".." as Player

func _on_player_jump_ground() -> void:
	if not jump_particles:
		return
	var particles = jump_particles.instantiate() as GPUParticles3D
	parent.add_child(particles)

func _on_player_jump_air() -> void:
	pass # Replace with function body.


func _on_player_just_landed() -> void:
	if not fall_particles:
		return
	var particles = fall_particles.instantiate() as GPUParticles3D
	parent.add_child(particles)
	particles.top_level = true
	particles.global_position = parent.get_last_slide_collision().get_position()
	particles.emitting = true
