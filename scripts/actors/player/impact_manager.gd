
extends AudioStreamPlayer

@export var player: Player
var land_impacts = [preload("res://assets/sound/land/land_impact_1.wav"), preload("res://assets/sound/land/land_impact_2.wav"), preload("res://assets/sound/land/land_impact_3.wav")]
func _ready() -> void:
	if player:
		player.just_landed.connect(_on_player_just_landed)
func _on_player_just_landed() -> void:
	pitch_scale = randf_range(0.8, 1.2)
	if abs(player.former_velocity.y) < 15:
		stream = land_impacts[0]
		volume_db = -12
		play()
	elif abs(player.former_velocity.y) < 30:
		stream = land_impacts[1]
		volume_db = -4
		play()
	else:
		stream = land_impacts[2]
		volume_db = clamp(abs(player.former_velocity.y) - 30, 0, 5)
		play()
