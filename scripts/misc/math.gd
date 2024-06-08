
extends Object
class_name Math
static func lerp_all(entity: Node3D, target: float, weight: float, delta: float):
	entity.rotation.x = lerp_angle(entity.rotation.x, target, weight * delta)
	entity.rotation.y = lerp_angle(entity.rotation.y, target, weight * delta)
	entity.rotation.z = lerp_angle(entity.rotation.z, target, weight * delta)

static func get_vec3xz(v: Vector3) -> Vector3:
	return Vector3(v.x, 0.0, v.z)
