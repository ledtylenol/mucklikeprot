
extends Node
signal died
signal change_label
var player: Player
var main_scene: Node3D
var item_node: Node3D
var entity_scene: Node3D
signal current_slot
signal select_slot
signal toggle_inventory(bool)
const ITEM = preload("res://scenes/inventory/item.tscn")
var use_cooldown := 0.0
var text_rows: Dictionary

var signal_text = ""
func _physics_process(_delta: float) -> void:
	if Input.is_key_label_pressed(KEY_F5):
		get_tree().reload_current_scene()
func set_row(idx: int, text: String):
	text_rows[idx] = text
func update_signal_text():
	signal_text = ""
	for row in text_rows.values():
		signal_text += row + '\n'
	change_label.emit(signal_text)
func on_drop_slot(position: Vector3, slot_data: InvSlotData, velocity: Vector3 = Vector3.ZERO) -> void:
	var pick_up = ITEM.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = position
	pick_up.velocity = velocity * 5
	item_node.add_child(pick_up)
	pick_up.velocity = velocity * 5

func spawn_entity_at(entity: Node3D, position: Vector3, parent: String, basis = Basis()):
	match parent:
		"main":
			main_scene.add_child(entity)
			entity.position = position
			entity.basis = basis
		"entity":
			entity_scene.add_child(entity)
			entity.position = position
			entity.global_basis = basis
			print("%s %s %s \n %s" % [position, basis, entity, entity.global_basis])
signal remove_slot(slot, id)
signal try_add_item(slot_data)
signal external_inventory(inventory: InventoryData)
signal show_inventories()
