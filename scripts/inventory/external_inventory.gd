extends Inventory
class_name ExternalInventory

@onready var panel_container: PanelContainer = $InventoryInterface/PanelContainer

func hide_inv():

	if tween:
		tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
	tween.tween_property(inventory_interface, "position", Vector2.RIGHT * 20, 0.3)
	tween.tween_property(inventory_interface, "modulate:a", 0.0, 0.3)
	if grab_slot.slot_data:
		GlobalObserver.on_drop_slot(player.global_position, grab_slot.slot_data, -player.global_basis.z)
		grab_slot.slot_data = null
		for slot in select_array:
			slot.selected = false
			slot.tween_deselected()
		select_array.clear()
	await tween.finished
	inventory_interface.visible = false

func show_inv():

	inventory_interface.visible = true
	if tween:
		tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
	tween.tween_property(inventory_interface, "position", Vector2.ZERO, 0.3)
	tween.tween_property(inventory_interface, "modulate:a", 1.0, 0.3)
	
