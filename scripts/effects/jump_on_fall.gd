extends EffectBase
class_name JumpOnFall
func on_add(parent):
	if not parent is Player:
		return
	var player = parent as Player
	if not player.just_landed.is_connected(player.do_ground_jump):
		player.just_landed.connect(player.do_ground_jump)
func on_remove(parent):
	if not parent is Player:
		return
	var player = parent as Player
	if player.just_landed.is_connected(player.do_ground_jump):
		player.just_landed.disconnect(player.do_ground_jump)
