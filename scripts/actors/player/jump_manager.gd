
extends AudioStreamPlayer
@export var player: Player


func _ready():
	if player:
		player.jump_ground.connect(_on_player_jump_ground)
		player.jump_super.connect(_on_player_jump_super)
func _on_player_jump_ground() -> void:
	volume_db = 0
	pitch_scale = 1.0
	play()



func _on_player_jump_super() -> void:
	pitch_scale = 0.7
	play()
	await get_tree().create_timer(0.3).timeout
	volume_db = -8
	play()
	await get_tree().create_timer(0.3).timeout
	volume_db = -18
	play()
