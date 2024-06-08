extends PanelContainer
class_name Slot

@onready var texture: TextureRect = $Texture
@onready var label: Label = $Label

var is_on_mouse: bool = false
var slot_data: InvSlotData:
	set(value):
		slot_data = value
		if is_node_ready():
			if slot_data and slot_data.quantity == 0:
				slot_data = null
			update_stuff()
var tween: Tween
@export var is_grab_slot: bool = false
signal clicked(idx, mouse_button, double)
signal released(idx, mouse_button)
signal hover(idx)
signal update(idx)
var tweenable: bool = true
var selected: bool = false:
	set(value):
		if value:
			tween_selected()
		else:
			tween_deselected()
		selected = value
func _ready() -> void:
	if is_grab_slot:
		self_modulate.a = 0.0

func _on_mouse_entered() -> void:
	hover.emit(get_index())
	is_on_mouse = true
	if selected or not tweenable:
		return
	if tween:
		tween.stop()
	tween = get_tree().create_tween()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "self_modulate", Color(0.1, 0.1, 0.1, 0.1), 0.5)


func _on_mouse_exited() -> void:
	is_on_mouse = false
	if selected or not tweenable:
		return
	if tween:
		tween.stop()
	tween = get_tree().create_tween()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "self_modulate", Color.WHITE, 0.5)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.is_released() \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT):
		released.emit(get_index(), event.button_index)
	if event is InputEventMouseButton \
			and event.is_pressed() \
			and (event.button_index == MOUSE_BUTTON_LEFT \
			or event.button_index == MOUSE_BUTTON_RIGHT \
			or event.button_index == MOUSE_BUTTON_MIDDLE):
		clicked.emit(get_index(), event.button_index, event.is_double_click())

func update_stuff() -> void:
	label.pivot_offset = Vector2(label.size.x / 2.0, label.size.y / 2.0)
	if slot_data:
		if slot_data.item_data and slot_data.item_data.texture:

			texture.texture = slot_data.item_data.texture

			label.text = str("%s" % slot_data.quantity) \
					if slot_data.quantity > 1 \
					else ""
	else:
		texture.texture = null
		label.text = "WOA"
	if is_grab_slot:
		if slot_data:
			visible = true
		else:
			visible = false
	update.emit(get_index())

func pop_slot_data() -> InvSlotData:
	var slot = slot_data
	slot_data = null
	return slot

func swap_slot_data(other: Slot) -> void:
	var temp = slot_data
	slot_data = other.slot_data
	other.slot_data = temp

func split_slot_data(others: Array[Slot]) -> void:
	if not slot_data or not slot_data.quantity:
		return

	var division := floori(slot_data.quantity / others.size())
	var last_slot
	for slot in others:
		slot.try_merge_some(slot_data, division)
		slot.update_stuff()
		update_stuff()
		last_slot = slot
	if slot_data.quantity >= 0 and last_slot.slot_data.quantity + slot_data.quantity < \
			last_slot.slot_data.item_data.max_stack_limit \
			and slot_data.item_data == last_slot.slot_data.item_data:
		last_slot.slot_data.quantity += slot_data.quantity
		slot_data.quantity = 0
		slot_data = null
		update_stuff()
		last_slot.update_stuff()


func try_merge_some(data: InvSlotData, amount: int) -> bool:
	if not slot_data:
		slot_data = data.duplicate()
		if data.quantity - amount <= 0:
			slot_data.quantity = data.quantity
			data.quantity = 0
			data = null
			update_stuff()
			return true
		slot_data.quantity = amount
		data.quantity -= amount
		return true
	if slot_data.item_data != data.item_data:
		return false
	if data.item_data == slot_data.item_data \
			and data.quantity + slot_data.quantity \
			< data.item_data.max_stack_limit:
		if data.quantity - amount < 0:
			slot_data.quantity += data.quantity
			data = null
			update_stuff()
			return true
		slot_data.quantity += amount
		data.quantity -= amount
		update_stuff()
		return true
	return false

func try_merge_fully(other: Slot) -> bool:
	if not other.slot_data:
		return false
	if not slot_data:
		slot_data = other.slot_data.duplicate()
		slot_data.quantity = other.slot_data.quantity
		other.slot_data = null
		update_stuff()
		other.update_stuff()
		return true
	if other.slot_data.item_data != slot_data.item_data:
		return false
	var sum := slot_data.quantity + other.slot_data.quantity
	if sum <= slot_data.item_data.max_stack_limit:
		slot_data.quantity = sum
		other.slot_data.quantity = 0
		other.slot_data = null

		update_stuff()
		other.update_stuff()
		return true
	return false

func data_try_merge_fully(other: InvSlotData) -> bool:

	if not slot_data:
		slot_data = other.duplicate()
		other.quantity = 0
	if not slot_data.item_data:
		slot_data = other.duplicate()
		slot_data.quantity = other.quantity
		other.quantity = 0
		update_stuff()
		return true
	if other.item_data != slot_data.item_data:
		return false
	var sum := slot_data.quantity + other.quantity
	if sum < slot_data.item_data.max_stack_limit:
		slot_data.quantity = sum
		other.quantity = 0
		update_stuff()
		return true
	return false

func data_try_merge_partially(other: InvSlotData) -> bool:
	if not slot_data:
		slot_data = other.duplicate()
		other.quantity = 0
		return true
	if slot_data.quantity == slot_data.item_data.max_stack_limit:
		return false
	if data_try_merge_fully(other):
		return true
	if other.item_data != slot_data.item_data:
		return false
	if not slot_data.item_data:
		slot_data = other.duplicate()
		slot_data.quantity = other.quantity
		other.quantity = 0
		update_stuff()
		return true
	var old_quantity = slot_data.quantity
	slot_data.quantity = slot_data.item_data.max_stack_limit
	other.quantity = other.quantity - (slot_data.item_data.max_stack_limit - old_quantity)
	update_stuff()
	return true

func tween_selected():
	if not tweenable:
		return
	if tween:
		tween.stop()
	tween = get_tree().create_tween()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_parallel(true)
	self_modulate = Color.WHITE
	tween.tween_property(self, "modulate", Color.AQUAMARINE, 0.5)
	tween.tween_property(label, "scale", Vector2(0.5, 0.5), 1.5)
func tween_deselected():
	if not tweenable:
		return
	tween = get_tree().create_tween()\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_parallel(true)
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)
	tween.tween_property(label, "scale", Vector2.ONE, 1.5)

func try_merge_partially(other_slot: Slot) -> bool:
	var other := other_slot.slot_data
	if not other:
		return false
	if not slot_data:
		slot_data = other.duplicate()
		other.quantity = 0
		other = null
		return true
	if slot_data.quantity == slot_data.item_data.max_stack_limit:
		return false
	if try_merge_fully(other_slot):
		return true
	if other.item_data != slot_data.item_data:
		return false
	if not slot_data.item_data:
		slot_data = other.duplicate()
		slot_data.quantity = other.quantity
		other.quantity = 0
		other = null
		update_stuff()
		return true
	var old_quantity = slot_data.quantity
	slot_data.quantity = slot_data.item_data.max_stack_limit
	other.quantity = other.quantity - (slot_data.item_data.max_stack_limit - old_quantity)
	if other_slot.slot_data.quantity < 1:
		other_slot.slot_data = null
	other_slot.update_stuff()
	update_stuff()
	return true

func can_partially_merge_with(other: Slot) -> bool:
	if not slot_data:
		return true
	if not other.slot_data or other.slot_data.item_data != slot_data.item_data:
		return false
	return true
