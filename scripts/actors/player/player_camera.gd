extends Camera3D
class_name PlayerCamera
@export var parent: Player
@export var pan_node: Node3D
@export_range(0.0, 1.0) var movement_tilt: float = 0.0
@export_range(0.0, 1.0) var camera_tilt: float = 1.0
var target_rotation_z := 0.0
@export_range(1.0,100.0) var sensitivity := 50.0:
	set(value):
		sensitivity = value
@export var y_offset: float = 3.0
var target_fov = 90.0
var markers: Array[Marker3D]
func _ready() -> void:
	for child in get_children():
		if child is Marker3D:
			markers.push_back(child)
	if parent:
		parent.just_landed.connect(_on_player_just_landed)
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			GlobalObserver.toggle_inventory.emit()
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			GlobalObserver.toggle_inventory.emit()
	handle_fov(delta)
	for child in markers:
		child.basis = self.global_basis
	var x = -Input.get_axis("left", "right") * movement_tilt
	pan_node.rotation.z = lerp_angle(pan_node.rotation.z, x * PI/16.0, delta * 3)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		parent.rotate_y(-event.relative.x * sensitivity / 4000.0) 
		rotate_x(-event.relative.y * sensitivity / 4000.0)
		rotation.x = clamp(rotation.x, -PI/2, PI/2)
		pan_node.rotate_z((-event.relative.x * camera_tilt)/4000.0)
		pan_node.rotation.z = clampf(pan_node.rotation.z, -PI/16, PI/16)


func _on_player_just_landed() -> void:
	var remainder = min(abs(parent.former_velocity.y / 10.0), 1.3)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(false)
	tween.tween_property(self, "position:y", (-remainder * 0.5) + y_offset, 0.1)
	tween.tween_property(self, "position:y", y_offset, 1.5)



func handle_fov(delta: float):
	var vel_length = Vector2(parent.velocity.x, parent.velocity.z).length()
	var vel_horizontal = Vector3(parent.velocity.x,0,parent.velocity.z).normalized()
	var basis_horizontal = Vector3(parent.basis.z.x, 0, parent.basis.z.z).normalized()
	target_fov = clampf(90 + 15 * vel_length * max((-basis_horizontal).dot(vel_horizontal), 0) / (parent.stats.speed) * (parent.stats.speed/30), 75, 110)
	fov = lerpf(fov, target_fov, 1.0-exp(-(delta*2)))
