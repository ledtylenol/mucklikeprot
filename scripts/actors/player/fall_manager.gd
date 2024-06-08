
extends AudioStreamPlayer

@export var player: Player

func _ready() -> void:
	if player:
		player.just_landed.connect(_on_player_just_landed)
func _on_player_just_landed() -> void:
	pitch_scale = randf_range(0.9, 1.1)
	if abs(player.former_velocity.y) < 15:
		volume_db = -12
		play()
	elif abs(player.former_velocity.y) < 30:
		volume_db = -8
		play()
	else:
		volume_db = clamp(abs(player.former_velocity.y) - 30, 0, 3)
		play()
