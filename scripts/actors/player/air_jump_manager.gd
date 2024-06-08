
extends AudioStreamPlayer
@export var player: Player

func _ready() -> void:
	if player:
		player.jump_air.connect(_on_player_jump_air)

func _on_player_jump_air() -> void:
	play()
