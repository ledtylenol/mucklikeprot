
extends Node3D
const node_3d = preload("res://scenes/node_3d.tscn")
var former_scene: Node3D
var new_scene: Node3D
signal transition_level
@onready var area_3d: Area3D = $DeathArea
@onready var world_environment: WorldEnvironment = $WorldEnvironment
var tween: Tween
var thread: Thread
const MAIN_ENV = preload("res://assets/environments/main_env.tres")
func _ready() -> void:
	new_scene = node_3d.instantiate()
	add_child(new_scene)
	GlobalObserver.died.connect(on_dead)
	transition_level.connect(on_level_transition)
	GlobalObserver.main_scene = new_scene
	GlobalObserver.entity_scene = $Entities

func on_dead():
	area_3d.set_deferred("monitoring", true)
	area_3d.set_deferred("monitorable", true)
	area_3d.visible = true

func on_level_transition(_new_level: String):
	if tween:
		tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(false)
	var old_dens = world_environment.environment.volumetric_fog_density
	tween.tween_property(world_environment, "environment:volumetric_fog_density", 1.15, 1.0)
	#former_scene = new_scene
	#new_scene = load_level(new_level)
	tween.tween_callback(func(): GlobalObserver.player.global_position = Math.get_vec3xz(GlobalObserver.player.global_position) + Vector3.UP * 200)
	tween.chain().tween_property(world_environment, "environment:volumetric_fog_density", old_dens, 1.0)
	await get_tree().create_timer(0.2).timeout
	#add_child(new_scene)
	#new_scene.global_position = Vector3(0.0, -800.0, 0.0)
	#var player_pos = GlobalObserver.player.global_position.y - new_scene.global_position.y
	#former_scene.global_position = Vector3(0.0, -800.0, 22220.0)
	#former_scene.queue_free()
	#new_scene.global_position = Vector3.ZERO
	#GlobalObserver.player.global_position = Vector3.ZERO + Vector3.UP * player_pos
	#GlobalObserver.main_scene = new_scene
	GlobalObserver.player.global_position = Math.get_vec3xz(GlobalObserver.player.global_position) + Vector3.UP * 200

func load_level(file: String) -> Node3D:
	var level = load(file).instantiate()
	return level

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_F5:
		world_environment.environment = load("res://assets/environments/main_env.tres")

