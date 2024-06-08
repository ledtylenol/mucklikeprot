extends Area3D
class_name CamTraumaNode
@onready var initial_rotation = $PanNode/PlayerCamera.rotation_degrees as Vector3
@export_category("Camera Shake")
@export var trauma_noise: FastNoiseLite
@export var trauma_reduction_rate: float = 1.0
@export var noise_speed := 50.0
@export var max_x := 10.0
@export var max_y := 10.0
@export var max_z := 5.0
var trauma_added = false
var trauma := 0.0:
	set(value):
		if value > trauma or trauma_added:
			trauma = clampf(value, 0.0, 1.0)
var time := 0.0
func _process(delta: float) -> void:
	time += delta
	trauma_added = true
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
	trauma_added = false
	rotation_degrees.x = initial_rotation.x + max_x * get_shake_intensity() * get_noise_from_seed(0)
	rotation_degrees.y = initial_rotation.y + max_y * get_shake_intensity() * get_noise_from_seed(1)
	rotation_degrees.z = initial_rotation.z + max_z * get_shake_intensity() * get_noise_from_seed(2)
func add_trauma(value: float):
	trauma_added = true
	trauma = clamp(trauma + value, 0.0, 1.0)
	trauma_added = false
func get_shake_intensity() -> float:
	return trauma * trauma

func get_noise_from_seed(seeds: int) -> float:
	trauma_noise.seed = seeds
	return trauma_noise.get_noise_1d(time * noise_speed)
