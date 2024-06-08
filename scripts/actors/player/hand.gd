extends Marker3D
class_name Hand
@onready var hand_mesh: MeshInstance3D = $HandMesh
var target := Vector3.ZERO
func set_hand(slot_data: InvSlotData) -> void:
	if slot_data and slot_data.item_data.mesh:
		hand_mesh.mesh = slot_data.item_data.mesh
	else:
		hand_mesh.mesh = null

func _physics_process(delta: float) -> void:
	global_basis = get_parent().global_basis
	target = get_parent().global_position - global_basis.z + global_basis.x - global_basis.y/2.0
	global_position = global_position.lerp(target, delta * 30)
