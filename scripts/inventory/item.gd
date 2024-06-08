extends CharacterBody3D
class_name InvItem

@export var slot_data: InvSlotData

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var detection_area: Area3D = $DetectionArea
@onready var collision_area: Area3D = $CollisionArea

@onready var mesh: MeshInstance3D = $Mesh
@onready var second_order_dynamics: SecondOrderDynamics = $SecondOrderDynamics
var target
@onready var time_since_spawned := 0.0
@onready var label_3d: Label3D = $Label3D
var dead := false
func _ready() -> void:
	var item_data = slot_data.item_data

	if item_data:
		slot_data.item_data = item_data.duplicate()
		if item_data.mesh:
			mesh.mesh = item_data.mesh
	second_order_dynamics.init(global_position)
	item_data = item_data.duplicate()
	if slot_data:
		slot_data = slot_data.duplicate()
	label_3d.text = str("%sx" % slot_data.quantity)
	detection_area.set_deferred("monitoring", false)
	collision_area.set_deferred("monitoring", false)
	await get_tree().create_timer(1.0).timeout
	detection_area.set_deferred("monitoring", true)
	collision_area.set_deferred("monitoring", true)

func _physics_process(delta: float) -> void:
	time_since_spawned += delta
	if target  \
			and time_since_spawned > 1.0:
		velocity = second_order_dynamics.update(global_position, target.global_position, delta)[1]
		set_deferred("collision_shape_3d.disabled", true)
		for col in collision_area.get_overlapping_bodies():
			if col is Player and not dead:
				_on_collision_area_body_entered(col)
	else:
		second_order_dynamics.init(global_position)
		velocity.x = lerpf(velocity.x, 0.0, delta * 5)
		velocity.z = lerpf(velocity.z, 0.0, delta * 5)
		velocity.y -= 5.0 * delta
		if is_on_floor():
			velocity.y = 0.0
		set_deferred("collision_shape_3d.disabled", false)
	move_and_slide()

func _on_detection_area_body_entered(body: Node3D) -> void:
	if body is Player:
		target = body


func _on_collision_area_body_entered(body: Node3D) -> void:
	if slot_data and body is Player:

		if body.inventory.try_add_item(slot_data):

			if slot_data.quantity < 1:
				print(slot_data.quantity)
				dead = true
				queue_free()
			body.play_pickup()

func on_remove(_id):
	queue_free()
