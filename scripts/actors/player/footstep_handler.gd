extends AudioStreamPlayer
class_name FootstepsManager
@export var initial_speed: float = 0.25
var delay = 0
var can_play = true
@onready var speed: float = 0
@onready var dirt_footsteps: Array[AudioStream] = [preload("res://assets/sound/footsteps/dirt1.mp3"), preload("res://assets/sound/footsteps/dirt2.mp3"), preload("res://assets/sound/footsteps/dirt3.mp3"), preload("res://assets/sound/footsteps/dirt4.mp3")]
@onready var stone_footsteps: Array[AudioStream]= [preload("res://assets/sound/footsteps/stone1.mp3"), preload("res://assets/sound/footsteps/stone2.mp3"), preload("res://assets/sound/footsteps/stone3.mp3"), preload("res://assets/sound/footsteps/stone4.mp3")]
@export var parent: CharacterBody3D
var time_since_last_step = 0
@onready var footsteps: Array[AudioStream] = stone_footsteps:
	set(value):
		footsteps = value
		set_streams(footsteps)

func _ready() -> void:
	volume_db = -80
	set_streams(footsteps)

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("crouch"):
		return
	delay -= delta
	delay = max(delay, 0)
	speed = 1.0 / (parent.velocity.length() * 0.7)
	time_since_last_step += delta
	if not is_zero_approx(delay) or not can_play:
		return
	if (not playing or time_since_last_step > speed) and parent.is_on_floor() and parent.velocity.length()>1:
		play()
		time_since_last_step = 0
	if parent.velocity.length()>1 and parent.is_on_floor():
		volume_db = -10 
#	elif not get_parent().wish_jump:
#		volume_db = -80

func set_streams(_floor: Array[AudioStream]):
	stream.streams_count = footsteps.size()
	for i in footsteps.size():
			stream.set_stream(i, footsteps[i])


func _on_player_just_landed() -> void:
	delay = 0.2


func _on_health_component_dead() -> void:
	can_play = false
