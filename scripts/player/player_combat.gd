extends Node
class_name player_attack

func process(player, delta):
	if player.action_just_free:
		player.get_node("AttackBox/LightAttack1CollisionShape").set_deferred("disabled", true)
		player.get_node("AttackBox/LightAttack2CollisionShape").set_deferred("disabled", true)
		player.get_node("AttackBox/HeavyAttackCollisionShape").set_deferred("disabled", true)
		if not player.action_queue.is_empty():
			var action = player.action_queue.pop_front()
			try_change_state(player, action)
	if GameInputMapper.is_action_just_pressed("light_attack"):
		if player.state == player.State.LIGHT_ATTACK_1:
			try_change_state(player, player.State.LIGHT_ATTACK_2)
		else: try_change_state(player, player.State.LIGHT_ATTACK_1)
		
	elif GameInputMapper.is_action_just_pressed("heavy_attack"):
		try_change_state(player, player.State.HEAVY_ATTACK)

func try_change_state(player, next_state):
	if player.state_lock_time > 0:
		if player.state_lock_time <= 0.6 and possible(player,next_state):
			print('push action to queue')
			player.action_queue.push_back(next_state)
		return
	if not player.is_on_floor() and player.air_attack_qouta < 1:
		return
	if next_state == player.State.LIGHT_ATTACK_1:
		change_state(player, "LightAttack1",player.State.LIGHT_ATTACK_1,0.6,0.08,1)
	if next_state == player.State.LIGHT_ATTACK_2:
		change_state(player, "LightAttack2",player.State.LIGHT_ATTACK_2,0.2,0.08, 0)
	if next_state == player.State.HEAVY_ATTACK:
		change_state(player, "HeavyAttack",player.State.HEAVY_ATTACK,0.8,0.15, 1)

func change_state(player, node_name, next_state, lock_time, hang_time, qouta_used):
	player.get_node("AttackBox/"+node_name+"CollisionShape").set_deferred("disabled", false)
	player.state = next_state
	player.state_lock_time = lock_time
	
	# Movement 
	player.hang_time = hang_time
	if not player.is_on_floor():
		player.air_attack_qouta = player.air_attack_qouta - qouta_used
		
func possible(player, new_state):
	if new_state in player.action_queue:
		print('action already queued')
		return false
	if player.state == player.State.LIGHT_ATTACK_1 and new_state == player.State.LIGHT_ATTACK_2:
		return true
	if player.state == player.State.LIGHT_ATTACK_2 and new_state == player.State.LIGHT_ATTACK_1:
		return true
	if new_state == player.State.HEAVY_ATTACK:
		return true
	return false
