extends Node3D
var opened = false
@export var animation: AnimationPlayer
@export var item: PassiveItemBase
const ITEM_HOLDER = preload("res://scenes/item_holder.tscn")
var time_since_opened := 0.0
var tween: Tween
var item_holder: ItemHolder
func _ready():
	item = item.duplicate(true)
func _on_collision__interacted() -> void:
	if not opened:
		animation.play("open")
	else:
		animation.play("close")

func open():
	time_since_opened = 0.0
	if tween:
		tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if item:
		item_holder = ITEM_HOLDER.instantiate()
		item_holder.item = item
		item_holder.picked_up.connect(on_item_pickup)
		$OpenChestChime.play()
		get_parent().add_child(item_holder)
		item_holder.global_position = global_position
		item = null
		$OpenChestChime.play()
	opened = true
	
	if item_holder:
		tween.tween_property($OpenChestChime2, "volume_db", 0.0, 1)
	print(0.0 - (float(item == null) * 80))
func close():
	if tween:
		tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($OpenChestChime2, "volume_db", -80.0, 2)
	opened = false
	
func _physics_process(delta: float) -> void:
	if opened:
		time_since_opened += delta
	else:
		time_since_opened = 0.0
	$Sprinkles.emitting = time_since_opened > 0.1 and item_holder != null

func on_item_pickup() -> void:
	if tween:
		tween.stop()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($OpenChestChime2, "volume_db", -80.0, 2)
