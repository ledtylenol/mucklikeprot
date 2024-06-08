extends Area3D
var player
var did_transition = false
var level = 0
func _ready() -> void:
	player = GlobalObserver.player
func _process(_delta: float) -> void:
	player = GlobalObserver.player
	if player and player.global_position.y < global_position.y and not did_transition:
		if false:
			transition_new_level()
		else:
			get_parent().transition_level.emit("self")
		did_transition = true
	elif player and player.global_position.y > -200:
		did_transition = false
func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		get_parent().transition_level.emit()

func transition_new_level():
	pass
