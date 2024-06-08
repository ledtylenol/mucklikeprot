extends Inventory
class_name Hotbar

@onready var panel: PanelContainer = $InventoryInterface/PanelContainer

var selected_idx := 0
var selected_slot: Slot:set = select_slot
var slot_tween: Tween
func hide_inv():
	if tween:
		tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
	#tween.tween_property(inventory_interface, "modulate:a", 0.4, 0.3)
	tween.tween_property(panel, "self_modulate:a", 0.0, 0.3)
	if grab_slot.slot_data:
		GlobalObserver.on_drop_slot(player.global_position, grab_slot.slot_data, -player.global_basis.z)
		grab_slot.slot_data = null
		for slot in select_array:
			slot.selected = false
			slot.tween_deselected()
		select_array.clear()

func show_inv():
	inventory_interface.visible = true
	if tween:
		tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
	tween.tween_property(inventory_interface, "modulate:a", 1.0, 0.3)
	tween.tween_property(panel, "self_modulate:a", 1.0, 0.3)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() \
			and event.keycode > KEY_0 and event.keycode < KEY_9:
		selected_idx = event.keycode - KEY_0 - 1
		if selected_slot:
			selected_slot.tweenable = true
			if slot_tween:
				slot_tween.stop()
			slot_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
			slot_tween.tween_property(selected_slot, "self_modulate", Color.WHITE, 0.5)
		selected_slot = slots[selected_idx]
		selected_slot.tweenable = false
		slot_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
		slot_tween.tween_property(selected_slot, "self_modulate", Color.CRIMSON, 0.5)

func select_slot(slot: Slot) -> void:
	selected_slot = slot
	player.hand.set_hand(selected_slot.slot_data)
