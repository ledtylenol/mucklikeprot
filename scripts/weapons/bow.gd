extends Weapon
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var can_shoot: bool = false
var string_pos = Vector3.ZERO
const LASER = preload("res://scenes/laser.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and not animation_player.is_playing():
			animation_player.play("joj")
		else:
			animation_player.play("ioi")
			if can_shoot:
				shoot()
		

func shoot() -> void:
	var laser = LASER.instantiate()

	var new_basis = Basis(get_parent_node_3d().global_basis.x, get_parent_node_3d().global_basis.y, -get_parent_node_3d().global_basis.z)
	laser.basis = new_basis
	GlobalObserver.spawn_entity_at(laser, global_position , "entity")

func set_shoot(scan_shoot: bool):
	self.can_shoot = scan_shoot
