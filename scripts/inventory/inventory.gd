extends Control

class_name Inventory
@export var grid: GridContainer 
const SLOT = preload("res://scenes/inventory/slot.tscn")
const TEST_1 = preload("res://scripts/inventory/test1.tres")

var slots: Array[Slot]
@onready var inventory_interface: Control = $InventoryInterface
@export var grab_slot: Slot
@export var sod: SecondOrderDynamics
@export var player: Player
@export var initial_inventory: InventoryData
var inventory: InventoryData
var tween: Tween
var select_array: Array[Slot]
var not_just_pressed: bool
var just_released: bool = false
@export var primary_inventory:= false
func _ready() -> void:
	populate_grid(initial_inventory)
	inventory = initial_inventory
	if sod:
		sod.init2(Vector2.ZERO)
	GlobalObserver.toggle_inventory.connect(on_inventory_toggle)
func populate_grid(inventory_data: InventoryData) -> void:
	clear_slots()
	for slot_data in inventory_data.slot_datas:
		var slot = SLOT.instantiate()
		slot.slot_data = slot_data
		grid.add_child(slot)
		slots.push_back(slot)
		slot.released.connect(on_released)
		slot.clicked.connect(on_clicked)
		slot.hover.connect(on_hover)
		slot.update.connect(on_update)
		slot.update_stuff()
	inventory = inventory_data

func on_released(idx: int, button: int) -> void:
	var slot = slots[idx]
	if not grab_slot.slot_data and not Input.is_action_just_pressed("shoot"):
		for slott in select_array:
			slott.selected = false
			slott.tween_deselected()
		select_array.clear()
	match [Input.is_key_pressed(KEY_SHIFT), grab_slot.slot_data, button]:
		[false, _, MOUSE_BUTTON_LEFT] when not_just_pressed \
				and select_array.size() >= 1 \
				and grab_slot.slot_data:
				grab_slot.split_slot_data(select_array)
				for slott in select_array:
					slott.selected = false
					slott.tween_deselected()
				select_array.clear()
		[false, _, MOUSE_BUTTON_LEFT]:
			if not slot.try_merge_partially(grab_slot):
				slot.swap_slot_data(grab_slot)
			inventory.slot_datas[idx] = slot.slot_data


func hide_inv():
	if tween:
		tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_parallel(true)
	tween.tween_property(inventory_interface, "position", Vector2.RIGHT * 20, 0.3)
	tween.tween_property(inventory_interface, "modulate:a", 0.0, 0.3)
	if grab_slot.slot_data:
		GlobalObserver.on_drop_slot(player.global_position, grab_slot.slot_data, -player.global_basis.z)
		grab_slot.slot_data= null
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
	
func on_clicked(idx: int, button: int, _double: bool) -> void:
	match button:
		MOUSE_BUTTON_LEFT:
			if not slots[idx] in select_array and grab_slot.slot_data:
				if slots[idx].slot_data and not slots[idx].can_partially_merge_with(grab_slot):
					return
				select_array.push_back(slots[idx])
				slots[idx].selected = true
				slots[idx].tween_selected()
		MOUSE_BUTTON_MIDDLE:
			sort()
func on_hover(idx: int) -> void:
	if not_just_pressed \
			or (Input.is_action_just_pressed("shoot")):
		if not slots[idx] in select_array and grab_slot.slot_data:
			if not slots[idx].can_partially_merge_with(grab_slot):
				return
			select_array.push_back(slots[idx])
			slots[idx].selected = true
			slots[idx].tween_selected()
	elif slots[idx].selected:
		slots[idx].selected = false
		slots[idx].tween_deselected()



func _process(delta: float) -> void:
	if not grab_slot.slot_data and sod:
		sod.init2(get_global_mouse_position())
		grab_slot.global_position = get_global_mouse_position()
	elif sod:
		grab_slot.global_position = sod.update(grab_slot.global_position, \
												get_global_mouse_position(), \
												delta)[0]

	#if Input.is_action_just_released("shoot") and not_just_pressed \
			#and select_array.size() >= 1:
		#grab_slot.split_slot_data(select_array)
	not_just_pressed = Input.is_action_pressed("shoot") and not Input.is_action_just_pressed("shoot")

func try_add_item(slot_data: InvSlotData) -> bool:
	for slot in slots:
		if slot.slot_data and slot.data_try_merge_partially(slot_data):
			return true
	for slot in slots:
		if not slot.slot_data and slot.data_try_merge_partially(slot_data):
			return true
	return false

func sort():
	var latest_free_idx = 0
	var first_free_idx = 0
	for i in range(0, slots.size()):
		if not slots[i].slot_data:
			latest_free_idx = i
			for j in range(i+1, slots.size()):
				if slots[j].slot_data:
					slots[i].slot_data = slots[j].slot_data
					slots[j].slot_data = null
					slots[i].update_stuff()
					slots[j].update_stuff()
					first_free_idx = i + 1

					break
		else:
			first_free_idx = i
	for i in range(0, first_free_idx+1):
		for j in range(i+1, first_free_idx+1):
			slots[i].try_merge_partially(slots[j])
	await get_tree().process_frame
	for i in range(0, first_free_idx+1):
		slots[i].update_stuff()
	update_all()
func clear_datas():
	for slot in slots:
		slot.slot_data = null
		slot.update_stuff()

func update_all():
	for slot in slots:
		slot.update_stuff()

func clear_slots():
	for child in grid.get_children():
		child.free()
	slots.clear()
func on_inventory_toggle():
	match Input.mouse_mode:
		Input.MOUSE_MODE_VISIBLE:
			show_inv()
		Input.MOUSE_MODE_CAPTURED:
			hide_inv()

func on_update(idx: int):
	if not inventory:
		return
	inventory.slot_datas[idx] = slots[idx].slot_data
