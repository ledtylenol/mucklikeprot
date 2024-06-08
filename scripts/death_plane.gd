extends Area3D
var player
func _ready():
	player = GlobalObserver.player

func _physics_process(_delta: float) -> void:
	player = GlobalObserver.player
	if monitoring and player.global_position.y < global_position.y:
		TransitionManager.do_death()
