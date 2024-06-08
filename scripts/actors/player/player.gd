extends Entity
class_name Player


const FRICTION: float = 6.0;
const STOP_SPEED: float = 1.0 * SCALE_FACTOR;
const SCALE_FACTOR: float = 0.03125;
const MAX_DASH_SPEED: float = 30.0;
const AIR_SPEED: float = 1.0;

signal just_left_ground()
signal just_landed()
signal jump_ground()
signal jump_air()
signal jump_super()
signal dashed()
signal item_added(item: PassiveItemBase)


@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
#@export_category("Inventory")
#@export var hotbar: Inventory
#@export var external_inventory: Inventory
#@export var inventory: Inventory
@export_category("")
@export var player_camera: PlayerCamera
@onready var pick_up: AudioStreamPlayer = $HUD/PickUp
@export var item_handler: ItemHandler
var heat: float = 0.0
var glidin: bool = false
var can_glide := false
var time_since_jump_press: float = 0.0
var time_since_not_grounded: float = 0.0
var time_since_crouch_press: float = 0.0
var current_air_coefficient: float = 0.1
var jumps_left: int = 0
@export var glide_duration: float = 2.5
var direction: Vector3 = Vector3.ZERO
var touched_ground: bool = false
var former_velocity: Vector3 = Vector3.ZERO
@export var jump_particle: PackedScene
@export var fall_particle: PackedScene
var let_go_of_space: bool = false
var did_super_jump: bool = false
var normal: Vector3 = Vector3.ZERO
var dead: bool = false
@export var auto_jump: bool = false
func _ready() -> void:
	GlobalObserver.player = self
	GlobalObserver.change_label.connect(on_label_change)
	#GlobalObserver.external_inventory.connect(on_external_inventory)
	#var bow = BOW.instantiate()
	#weapon_handler.add_child(bow)
func _on_health_component_dead() -> void:
	dead = true
	velocity = Vector3.ZERO
	GlobalObserver.died.emit()
	get_tree().reload_current_scene()
	return
	#$HealthComponent.set_deferred("monitoring", false)
	#$HealthComponent.set_deferred("monitorable", false)
	#var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT).set_parallel(true)
	#tween.tween_property(self, "position:y", position.y + 10, 3.0)
	#tween.tween_property($CameraTraumaNode, "trauma", 1.0, 1.5)
	#$HUD/Pain._color = Vector3(1.0, 0.0, 0.0)
	#tween.tween_property($HUD/Pain, "alpha", 1.0, 1.0)
	#tween.set_parallel(false)
	#tween.tween_property($CameraTraumaNode, "trauma", 0.6, 1.5)
	#await tween.finished
	#dead = false
	#collision_shape_3d.set_deferred("disabled", true)

func _process(delta: float) -> void:
	heat = max(heat - delta * 5, 0.0)
	GlobalObserver.use_cooldown = max(GlobalObserver.use_cooldown - delta, 0.0)
	GlobalObserver.set_row(1, "%.2f" % Math.get_vec3xz(velocity).length())
	GlobalObserver.set_row(2, "%.2f" % (get_floor_normal().dot(Vector3.UP)))
	GlobalObserver.set_row(3, "effective: %.2f\nbase: %.2f\nmul: %.2f\neff_mul: %.2f" % [ stats.speed * (10 + log((stats.speed_mul - 10)**3)), stats.speed, stats.speed_mul, (10 + log((stats.speed_mul - 10)**3))])
	GlobalObserver.update_signal_text()
	$RayCast3D.target_position = velocity
	$RayCast3D.global_position = global_position

func on_label_change(text: String):
	$HUD/Label.text = text

func play_pickup():
	heat += 1.0
	pick_up.pitch_scale = 1.0 + log(sqrt(heat))
	pick_up.play() 


func _physics_process(delta: float) -> void:
	if dead:
		return
	
	time_since_jump_press += delta
	process_inputs()
	check_ground(delta)
	if is_on_floor():
		move_ground(delta)
	else:
		move_air(delta)
	if do_ground_jump():
		jump_ground.emit()
		time_since_not_grounded = stats.coyote_time + 0.001
		let_go_of_space = false
	elif do_super_jump():
		jump_super.emit()
		did_super_jump = true
		let_go_of_space = false
		time_since_crouch_press = glide_duration + 0.001
	elif do_air_jump():
		jump_air.emit()
	
	glidin = do_glide(delta)
	if not glidin:
		apply_gravity(delta)
	
	
	if is_on_wall_only():
		normal = get_wall_normal()
		velocity = velocity.slide(normal)
	former_velocity = velocity
	move_and_slide()
func process_inputs():
	var dir = Input.get_vector("left", "right", "up", "down")
	direction = (dir.x * global_basis.x + dir.y * global_basis.z)
	if normal.length() > 0:
		direction = direction.slide(normal)

func check_ground(delta: float) -> void:
	if is_on_floor():
		normal = get_floor_normal()
		time_since_crouch_press = 0.0
		did_super_jump = false
		if not touched_ground:
			touched_ground = true
			if time_since_not_grounded > 0.2:
				just_landed.emit()
		time_since_not_grounded = 0.0
		jumps_left = stats.jump_count
	else:
		normal = Vector3.ZERO
		if touched_ground:
			touched_ground = false
			just_left_ground.emit()
		time_since_not_grounded += delta

func move_ground(delta: float) -> void:
	if Input.is_action_pressed("jump") and auto_jump:
		return
	if Input.is_action_pressed("crouch"):

		velocity += (global_basis.y * stats.fall_gravity * delta).slide(normal)
		if is_equal_approx(normal.dot(Vector3.UP), 1.0):
			if velocity.length() < 0.2:
				velocity = velocity.move_toward(Vector3(0, velocity.y, 0), delta)
			else:
				velocity -= Math.get_vec3xz(velocity).normalized() *0.2
		#if not(Input.is_action_pressed("jump") and auto_jump):
			#apply_floor_snap()
		
		return
	else:
		apply_friction(delta)
	var speed :float
	if stats.speed_mul > 10:
		speed = stats.speed * (10 + log((stats.speed_mul - 10)**3))
	else:
		speed = stats.speed * stats.speed_mul
	var new_vel := velocity
	var dot := new_vel.dot(direction)
	var add_speed: float
	if Input.is_action_pressed("walk"):
		add_speed = 5.0 - dot
	else:
		add_speed = speed - dot
	if add_speed <= 0.0:
		return
	var accel: float
	if Input.is_action_pressed("walk"):
		accel = 10.0 * 5.0 * delta
	else: 
		accel = maxf(1.0,stats.ground_acceleration) * speed * delta
	if add_speed > 50:
		accel *= add_speed / speed
	if accel > add_speed:
		accel = add_speed
	if stats.ground_acceleration < 1.0 and not Input.is_action_pressed("walk"):
		accel *= maxf(0.4, stats.ground_acceleration)
	GlobalObserver.set_row(9, "%.2f" % accel)
	velocity += accel * direction
func move_air(delta: float) -> void:
	var new_vel := velocity
	var dot := new_vel.dot(direction)
	var add_speed := AIR_SPEED - dot
	
	if add_speed <= 0.0:
		return
	
	var accel := maxf(1.0,stats.ground_acceleration) * 10 * stats.speed * delta * stats.speed_mul
	if accel > add_speed:
		accel = add_speed
	
	velocity += accel * direction

func apply_friction(delta: float) -> void:
	var new_velocity := velocity
	var speed := new_velocity.length()
	if speed < 0.001:
		return
	
	var control: float
	if speed < STOP_SPEED:
		control = STOP_SPEED
	elif auto_jump and Input.is_action_pressed("jump"):
		control = STOP_SPEED / 3
	else:
		control = speed
	
	var new_speed := speed - delta * control * FRICTION
	if new_speed <= 0.0:
		new_speed = 0.0
	
	new_speed /= speed
	velocity = new_velocity * new_speed

func do_ground_jump() -> bool:
	var can_jump := (Input.is_action_pressed("jump") and auto_jump) or (Input.is_action_just_pressed("jump"))
	if not is_on_floor() or time_since_not_grounded > stats.coyote_time or not can_jump:
		return false
	time_since_jump_press = 0.0
	velocity.y = stats.jump_velocity
	return true
	

func do_super_jump() -> bool:
	if not glidin or not Input.is_action_just_pressed("jump"):
		return false
	var jump_strength = stats.jump_velocity * 3.0
	velocity.y = jump_strength
	return true

func do_air_jump() -> bool:
	if not Input.is_action_just_pressed("jump"):
		return false
	if jumps_left < 1:
		return false
	let_go_of_space = false
	jumps_left -= 1
	velocity.y = stats.jump_velocity
	return true


func do_glide(delta: float) -> bool:
	GlobalObserver.set_row(0, "%s %s %s" % [is_on_floor(), time_since_crouch_press, Input.is_action_pressed("crouch")])
	if is_on_floor() or time_since_crouch_press > glide_duration or not Input.is_action_pressed("glide") or not can_glide:
		return false
	time_since_crouch_press += delta
	if velocity.y > 0.0:
		velocity.y = lerpf(velocity.y, -1.0, delta * 5.0)
	else:
		velocity.y = lerpf(velocity.y, -1.0, delta)
	velocity.x = lerpf(velocity.x, 0.0, delta * 5)
	velocity.z = lerpf(velocity.z, 0.0, delta * 5)
	return true

func apply_gravity(delta: float) -> bool:
	if is_on_floor() or velocity.y < -265:
		return false
	if not Input.is_action_pressed("jump"):
		let_go_of_space = true
	
	if velocity.y < 0.0:
		velocity += global_basis.y * stats.fall_gravity * delta
		return true
	else:
		if let_go_of_space and time_since_jump_press > stats.minimum_jump_duration:
			velocity += 2.0 * global_basis.y * stats.fall_gravity * delta
			return true
		velocity += global_basis.y * stats.jump_gravity * delta
		return true


func push_item(item: PassiveItemBase) -> void:
	item_added.emit(item)


#func on_external_inventory(inv: InventoryData, entity: Node3D) -> void:
	#if inv:
		#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#external_inventory.inventory = inv
		#external_inventory.populate_grid(external_inventory.inventory)
		#external_inventory.show_inv()
	#else:
		#external_inventory.inventory = null
		#external_inventory.hide_inv()
		#await external_inventory.tween.finished
		#external_inventory.clear_slots()


