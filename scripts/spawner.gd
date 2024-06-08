extends Marker3D
@export var target: Node3D
@export var number_of_floaters: int
@export var spawn_time: float
@export var spawn_items: bool
const ITEM = preload("res://scenes/inventory/item.tscn")
var x = 0.0
const FLOATER = preload("res://scenes/floater.tscn")
func _ready() -> void:
	await get_tree().create_timer(spawn_time).timeout
	for i in range(number_of_floaters):
			var rand_vec = Vector3(randf_range(-10, 10),randf_range(-1, 1),randf_range(-10, 10))
			var new_floater = FLOATER.instantiate()
			new_floater.initial_pos = global_position+ rand_vec
			new_floater.idle_target = new_floater.initial_pos
			get_parent().add_child(new_floater)
			new_floater.global_position = global_position + rand_vec
			new_floater.initial_pos = global_position+ rand_vec
			#new_floater.target = target

func _process(delta: float) -> void:
	x += delta
	if x > spawn_time and spawn_items:
		var item = ITEM.instantiate()
		get_parent().add_child(item)
		item.velocity = Vector3.UP * 5.0 + Vector3(randf(), randf(), randf()) * 3
		x = 0.0
		item.global_position = global_position
