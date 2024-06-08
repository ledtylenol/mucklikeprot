extends RigidBody3D
class_name ItemHolder
var item: PassiveItemBase
@onready var collision: CollisionShape3D = $CollisionShape3D

@onready var collision_shape_3d: CollisionShape3D = $SurfaceArea/CollisionShape3D

signal picked_up
func _ready() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	collision.set_deferred("disabled", true)
	if not item:
		queue_free()
	var mesh = MeshInstance3D.new()
	mesh.mesh = item.model
	collision_shape_3d.shape = item.model.create_convex_shape()
	add_child(mesh)
	tween.tween_property(mesh, "scale", Vector3.ONE, 0.5).from(Vector3.ZERO)
	apply_central_impulse(Vector3.UP * 5)
	await get_tree().create_timer(0.1).timeout
	collision.set_deferred("disabled", false)



func _on_surface_area_body_entered(body: Node3D) -> void:
	if body is Player and item:
		body.push_item(item)
		picked_up.emit()
		queue_free()
