
extends State
class_name FloaterChaseState
@export var nav: NavigationAgent3D
@export var desired_length: float
@export var desired_height: float
@onready var floater_mesh: Node3D = $"../../floater"
@onready var ring_1: MeshInstance3D = $"../../floater/Ring 1"
@onready var ring_2: MeshInstance3D = $"../../floater/Ring 1/Ring 2"
@onready var ring_3: MeshInstance3D = $"../../floater/Ring 1/Ring 2/Ring 3"
signal shoot
var initial_desired_length: float
var initial_height: float
@onready var on_screen_node: VisibleOnScreenNotifier3D = $"../../VisibleOnScreenNotifier3D"
var target_rotation = Vector3.ZERO
func _ready() -> void:
	initial_desired_length = desired_length
	initial_height = desired_height
	shoot.connect(entity.on_shoot)
var time_since_behind_player := 0.0 
func physics_update(delta: float):
	if not on_screen_node.is_on_screen():
		desired_height = maxf(desired_height - delta, 1.0)
		desired_length = maxf(desired_length - delta, 2.5)
		if desired_length < 3:
			pass
			#shoot.emit()
	else:
		desired_length = initial_desired_length
		desired_height = entity.height
		#shoot.emit()
	entity.front_cast.target_position = entity.velocity.slide(entity.normal).normalized() * 1.5
	entity.projected_vel = entity.velocity.slide(entity.normal).normalized()
	if entity.center_cast_2.is_colliding():
		do_collisions([entity.center_cast_2])
	elif entity.center_cast_1.is_colliding():
		do_collisions([entity.center_cast_1])

	if entity.front_cast.is_colliding():
		do_collisions([entity.front_cast])
	else:
		entity.quaternion = entity.quaternion.slerp(Quaternion.IDENTITY, delta * 5)
	entity.normal = entity.normal.normalized()
	var target = entity.target.global_position - (entity.target.global_position- entity.global_position).normalized() * desired_length
	nav.target_position = target
	var offset_2 = (nav.get_next_path_position() - entity.global_position)
	offset_2 = offset_2.slide(entity.normal)
	offset_2 = offset_2.limit_length(entity.max_offset)
	entity.velocity += (offset_2 * delta * entity.force_factor_2 - entity.damp_factor_2 * delta * entity.velocity.slide(entity.normal)).limit_length(entity.max_offset)

	entity.velocity += entity.force_factor * entity.offset.project(entity.normal) * delta - entity.damp_factor * entity.velocity.project(entity.normal) * delta
	entity.move_and_slide()
	floater_mesh.look_at(entity.target.global_position + entity.target.velocity, Vector3.UP, true)
	var speed = entity.velocity.length() / 5
	if entity.velocity.length() > 3.0:
		ring_1.rotate_x(delta*PI * 0.7 * speed + randf_range(0.001, 0.01))
		ring_2.rotate_y(delta*PI * 0.9 * speed + randf_range(0.001, 0.01))
		ring_2.rotate_x(delta*PI * 0.8 *speed + randf_range(0.001, 0.01))
		ring_3.rotate_y(delta*PI * 1.2 *speed + randf_range(0.001, 0.01))
	else:
		Math.lerp_all(ring_1, 0.0, 0.7, delta)
		Math.lerp_all(ring_2, 0.0, 0.8, delta)
		Math.lerp_all(ring_3, 0.0, 0.9, delta)

func _on_detection_area_body_exited(body: Node3D) -> void:
	if body is Player or body is DebugMarker:
		entity.initial_pos = entity.global_position
		entity.idle_target = entity.initial_pos
		transitioned.emit(self, "idle")


func do_collisions(casts: Array[RayCast3D]):
	if casts.size() == 1:
		var cast = casts[0]
		entity.normal =  cast.get_collision_normal()
		var q = Quaternion(entity.basis.y, entity.normal)
		entity.quaternion *= q
		entity.point = cast.get_collision_point()
		entity.offset = entity.point + desired_height * entity.normal - entity.global_position
	
	for cast in casts:
		entity.normal =  (entity.normal + cast.get_collision_normal()) / 2
		var q = Quaternion(entity.basis.y, entity.normal)
		entity.quaternion *= q
		entity.point = (entity.point + cast.get_collision_point())/ 2
		entity.offset = entity.point + desired_height * entity.normal - entity.global_position
