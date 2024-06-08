extends RayCast3D
@export var interact_label: Label3D
@export var interact_cursor: Node3D
@export var crosshair: TextureRect
var was_colliding = false
var target= Vector3.ZERO
var time_since_interact := 0.0
var time_value := 0.0
func _physics_process(delta: float) -> void:
	time_value += delta 
	if is_colliding() and get_collider() is Interactable:
		interact_cursor.rotate_x(sin(-time_value)/10)
		interact_cursor.rotate_z(cos(time_value)/10)
		interact_cursor.rotate_y(sin(time_value)/10)
		if not was_colliding and get_collider() is Interactable:
			was_colliding = true
			interact_label.global_position = get_collider().global_position
		interact_label.position = interact_label.position.lerp(target, delta * 10)
		interact_cursor.position = interact_cursor.position.lerp(target, delta * 10)
		for idx in interact_cursor.get_child_count():
			var child = interact_cursor.get_child(idx)
			child.position = child.position.lerp((1.0 + (0.7*sin(time_value) ** 3)) *Vector3.UP.rotated(Vector3.FORWARD, (PI/2.0)*idx), delta * 10)
		time_since_interact = 0.0
		target = get_collider().global_position
		interact_label.text = str("E \n %s" % get_collider().hover_text)
		if Input.is_action_just_pressed("interact"):
			get_collider().interacted.emit()
	else:

		time_since_interact += delta
		was_colliding = false
		interact_cursor.rotation = interact_cursor.rotation.slerp(Vector3.ZERO , delta*10)
		var FOG_VOLUME := load("res://scenes/fog_volume.tscn")
		var fog = FOG_VOLUME.instantiate()
		if is_colliding() and Input.is_action_just_pressed("shoot"):
			print("Fog")
			get_tree().root.add_child(fog)
			fog.global_position = get_collision_point() + Vector3.UP * 40
	interact_label.transparency = clamp((abs(time_since_interact)*2)**2, 0.0, 1.0)
	crosshair.modulate.a = lerpf(crosshair.modulate.a, clamp((time_since_interact*2)**2, 0.0, 1.0), delta * 10)
	for child in interact_cursor.get_children():
		child.position = child.position.lerp(Vector3.ZERO, delta * 10)
		child.transparency = clamp((time_since_interact*2)**2, 0.0, 1.0)
