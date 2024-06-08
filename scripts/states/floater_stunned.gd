
extends State
class_name FloaterStunnedState
var time_left = 0.0
@export var gravity: float
func enter():
	time_left = 3.0
	$"../../AudioStreamPlayer3D".play()
func physics_update(delta: float):

	entity.velocity += Vector3.DOWN * delta * gravity
	entity.velocity *= 0.9
	entity.move_and_slide()
	time_left -= delta
	if time_left <= 0:
		transitioned.emit(self, "idle")
