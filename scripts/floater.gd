
extends CharacterBody3D
class_name Floater
signal collided
@onready var center_cast_1: RayCast3D = $CenterCast
@onready var center_cast_2: RayCast3D = $CenterCast2
@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var laser_shoot: AudioStreamPlayer3D = $LaserShoot

@export var front_cast: RayCast3D
@onready var initial_height = height
@export var force_factor: float = 1.0
@export var damp_factor: float = 1.0
@export var force_factor_2: float = 1.0
@export var damp_factor_2: float = 1.0
@export var height: float = 1.0
@export var target: Node3D
@onready var idle_target: Vector3
@export var max_offset: float = 1.0
var initial_pos 
var offset = Vector3.ZERO
var normal = Vector3.UP
var point = Vector3.ZERO
var projected_vel = Vector3.ZERO
@onready var woosh_audio: AudioStreamPlayer3D = $AudioStreamPlayer3D
var cooldown := 5.0
const LASER = preload("res://scenes/laser.tscn")
func _ready() -> void:
	woosh_audio.play()
	front_cast.top_level = true
func _physics_process(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)
	$CenterCast2.global_position = global_position
	front_cast.global_position = global_position
	$floater.global_position = global_position
	woosh_audio.volume_db = linear_to_db(velocity.length() / 50)
	#rotate_y((basis.x).dot(projected_vel))
	nav.path_height_offset = -height

func on_shoot() -> void:
	if cooldown:
		return
	var laser = LASER.instantiate()
	laser.basis = $floater.basis
	laser.top_level = true
	$Bullets.add_child(laser)
	laser.global_position = global_position
	cooldown = randf_range(0.5, 6.5)
	laser_shoot.play()


func _on_health_component_dead() -> void:

	
	queue_free()
