
extends State
class_name FloaterIdleState
@export var idle_timer: Timer
var former_basis = Basis.IDENTITY
@export var nav: NavigationAgent3D
func enter():
	await ready
	idle_timer.start()

func exit():
	idle_timer.stop()

func physics_update(delta: float):
	if entity.get_last_slide_collision():
		var collider = entity.get_last_slide_collision()

		var speed = collider.get_collider_velocity()
		entity.velocity += speed
		if speed.length() > 0.1:
			transitioned.emit(self, "stunned")

	if entity.center_cast_1.is_colliding():
		do_collisions([entity.center_cast_1])
	else:
		entity.quaternion = entity.quaternion.slerp(Quaternion.IDENTITY, delta * 5)
	entity.normal = entity.normal.normalized()
	var offset_2 = entity.idle_target - entity.global_position
	offset_2 = offset_2.slide(entity.normal)
	offset_2 = offset_2.limit_length(entity.max_offset)
	entity.velocity += offset_2 * delta * entity.force_factor_2 - entity.damp_factor_2 * delta * entity.velocity.slide(entity.normal)

	entity.velocity += entity.force_factor * entity.offset.project(entity.normal) * delta - entity.damp_factor * entity.velocity.project(entity.normal) * delta

	#basis = basis.looking_at(velocity.normalized(), basis.y)
	former_basis = entity.basis
	entity.move_and_slide()

func _on_idle_timer_timeout() -> void:
	var rand = randf_range(0.0, 1.0)
	if rand < 0.3:
		entity.idle_target = Vector3(randf_range(-5.0, 5.0), 0.0, randf_range(-5.0,5.0)) + entity.initial_pos
		idle_timer.wait_time = randf_range(3,10)
	elif rand < 0.7:
		var initial_height = entity.height
		entity.height = 2 * initial_height
		await get_tree().create_timer(0.3).timeout
		entity.height = 0.5 * initial_height
		await get_tree().create_timer(0.6).timeout
		entity.height = initial_height
	else:
		var initial_height = entity.height
		entity.height = 10 * initial_height
		await get_tree().create_timer(0.3).timeout
		entity.height = 0.5 * initial_height
		await get_tree().create_timer(0.6).timeout
		entity.height = initial_height


func _on_floater_collided() -> void:
	pass # Replace with function body.


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is Player or body is DebugMarker:
		entity.target = body
		transitioned.emit(self, "chase")

func do_collisions(casts: Array[RayCast3D]):
	for cast in casts:
		entity.normal =  (entity.normal + cast.get_collision_normal()) / 2
		var q = Quaternion(entity.basis.y, entity.normal)
		entity.quaternion *= q
		entity.point = (entity.point + cast.get_collision_point())/ 2
		entity.offset = entity.point + entity.height * entity.normal - entity.global_position
