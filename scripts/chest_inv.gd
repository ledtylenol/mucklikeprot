extends Node3D

var opened := false
@onready var animation: AnimationPlayer = $AnimationPlayer
@export var inventory: InventoryData
func _physics_process(_delta: float) -> void:
	if GlobalObserver.player and GlobalObserver.player.global_position.distance_to(global_position) > 5:
		if opened:
			close()
func _on_collision__interacted() -> void:
	if not opened:
		open()
	else:
		close()

func open():
	opened = true
	animation.play("open")
	GlobalObserver.external_inventory.emit(inventory, self)
	GlobalObserver.toggle_inventory.emit()

func close():
	opened = false
	animation.play("close")
	GlobalObserver.external_inventory.emit(null, self)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() \
			and event.keycode == KEY_ESCAPE:
				if opened:
					close()
