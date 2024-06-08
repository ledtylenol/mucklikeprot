extends Node
@onready var light_woosh: AudioStreamPlayer = $LightWoosh
@onready var medium_woosh: AudioStreamPlayer = $MediumWoosh
@onready var hard_woosh: AudioStreamPlayer = $HardWoosh
@export var player: Player
@export_category("Curves")
@export var light: Curve
@export var medium: Curve
@export var hard: Curve
const SPEED := 180.0

var real_val: float
var relative := 0.0
func _ready() -> void:
	light_woosh.play()
	medium_woosh.play()
	hard_woosh.play()

func _physics_process(delta: float) -> void:
	var xz := Math.get_vec3xz(player.velocity).length()
	var vel := absf(player.velocity.y)
	vel = 0.3 * xz + 0.7 * vel
	real_val = minf((vel/SPEED), 1.0)
	relative = lerpf(relative, real_val, delta * 10)
	light_woosh.volume_db = linear_to_db(light.sample(relative))
	medium_woosh.volume_db = linear_to_db(medium.sample(relative))
	hard_woosh.volume_db = linear_to_db(hard.sample(relative))
	GlobalObserver.set_row(10, "%.2f" % relative)
