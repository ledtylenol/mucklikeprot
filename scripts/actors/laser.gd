extends CharacterBody3D

func _ready() -> void:
	velocity = basis.z * 15
	await get_tree().create_timer(10.0).timeout
	queue_free()
func _physics_process(_delta: float) -> void:
	move_and_slide()
