
extends Node
class_name ItemHandler
@export var base_stats: PlayerStats
@onready var current_stats = base_stats.duplicate()
@export var parent: Player
@export var items: Array[PassiveItemBase]
@export var weapon_handler: WeaponHandler
@export var effect_handler: EffectHandler
func _ready():
	base_stats.calculate_stuff()
	parent.jumps_left = base_stats.jump_count
	if parent is Player:
		parent.item_added.connect(_on_player_item_added)
		parent.stats = current_stats


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_page_up"):
		if items.size() >= 1:
			remove_item(items.back())

func _on_player_item_added(item: PassiveItemBase) -> void:
	items.append(item)
	item.do_start_effect(parent)
	if item.effect:
		effect_handler.push_effect(item.effect)

func remove_item(item: PassiveItemBase):
	item.do_remove_effect(parent)
	items.erase(item)

func remove_effect(effect: EffectBase, item: PassiveItemBase) -> void:
	item.do_remove_effect(parent)
	item.effect.active = false
