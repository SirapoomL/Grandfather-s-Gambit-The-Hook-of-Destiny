extends Node
class_name player_attack

func process(player, delta):
	player.i_frame = player.i_frame-delta if player.i_frame-delta > 0 else 0
	if player.just_take_damage > 0:
		player.just_take_damage = delta-player.just_take_damage if player.just_take_damage-delta > 0 else 0
	elif player.just_take_damage < 0:
		player.just_take_damage = abs(player.just_take_damage)-delta if player.just_take_damage+delta < 0 else 0 
	if player.is_on_floor():
		player.swing_attack_qouta = 1
		player.air_attack_qouta = 3
	
	if player.state in player.UNAFFECTED_BY_INPUT:
		if player.state not in player.ATTACK_STATE:
			return
	var light_attack = GameInputMapper.is_action_just_pressed("light_attack")
	var heavy_attack = GameInputMapper.is_action_just_pressed("heavy_attack")
	var left = GameInputMapper.is_action_pressed("move_left")
	var right = GameInputMapper.is_action_pressed("move_right")
	var attack_direction = true if left else ( false if right else player.face_left )
	if player.action_just_free:
		if not player.action_queue.is_empty():
			var action = player.action_queue.pop_front()
			if action[0] in player.ATTACK_STATE:
				try_change_state(player, action[0], action[1])
			else: player.action_queue.push_front(action)
	#if (light_attack or heavy_attack) and player.state in player.HOOKING_STATE:
		#try_change_state(player, player.State.HOOK_ATTACK, attack_direction)
	if light_attack:
		if player.state == player.State.HOOKING:
			try_change_state(player, player.State.SWING_ATTACK, attack_direction)
		elif player.state == player.State.LIGHT_ATTACK_1:
			try_change_state(player, player.State.LIGHT_ATTACK_2, attack_direction)
		else: try_change_state(player, player.State.LIGHT_ATTACK_1, attack_direction)
	elif heavy_attack:
		try_change_state(player, player.State.HEAVY_ATTACK, attack_direction)

func get_attack_damage(attack_power, current_state, State):
	if current_state == State.LIGHT_ATTACK_1:
		return 0.8 * attack_power
	if current_state == State.LIGHT_ATTACK_2:
		return 0.6 * attack_power
	if current_state == State.HEAVY_ATTACK:
		return 1.5 * attack_power
	if current_state == State.SWING_ATTACK:
		return attack_power
	return 0.5 * attack_power

func try_change_state(player, next_state, attack_direction):
	if player.state_lock_time > 0:
		if player.state_lock_time <= 0.6 and possible(player,next_state):
			print('push action to queue')
			player.action_queue.push_back([next_state,attack_direction])
		return
	if next_state == player.State.LIGHT_ATTACK_2:
		change_state(player, "LightAttack2",player.State.LIGHT_ATTACK_2,attack_direction,0.18,0.04, 0)
	if not player.is_on_floor() and player.air_attack_qouta < 1:
		return
	if next_state == player.State.LIGHT_ATTACK_1:
		change_state(player, "LightAttack1",player.State.LIGHT_ATTACK_1,attack_direction,0.5,0.04,1)
	if next_state == player.State.HEAVY_ATTACK:
		change_state(player, "HeavyAttack",player.State.HEAVY_ATTACK,attack_direction,0.8,0.08, 1)
	if next_state == player.State.SWING_ATTACK:
		if player.swing_attack_qouta < 1:
			return
		change_state(player, "SwingAttack",player.State.SWING_ATTACK,attack_direction,0.8,0.08, 1)

func change_state(player, node_name, next_state, attack_direction, lock_time, hang_time, qouta_used):
	#player.get_node("AttackBox/"+node_name+"CollisionShape").set_deferred("disabled", false)
	var player_pos = player.global_position.x
	var attack_pos = player.get_node("AttackBox/"+node_name+"CollisionShape").global_position.x
	var x_dist = player_pos - attack_pos if player_pos - attack_pos > 0 else attack_pos - player_pos
	var new_attack_pos = player_pos - x_dist if attack_direction else player_pos + x_dist
	player.get_node("AttackBox/"+node_name+"CollisionShape").global_position.x = new_attack_pos
	player.change_state(next_state)
	player.state_lock_time = lock_time
	
	player.face_left = attack_direction
	
	if attack_direction:
		player.global_position.x -= player.speed * 0.02
	else:
		player.global_position.x += player.speed * 0.02
	
	
	if next_state == player.State.SWING_ATTACK:
		player.swing_attack_qouta = player.swing_attack_qouta - qouta_used
	else:
	# Movement 
		player.hang_time = hang_time
		player.velocity.y  = 0
		#if player.state in player.NORMAL_STATE:
			#player.velocity.x = 0
		if not player.is_on_floor():
			player.air_attack_qouta = player.air_attack_qouta - qouta_used
		
func possible(player, new_state):
	for action in player.action_queue:
		if new_state == action[0]:
			print("Action already queued")
			return false
	if player.state == player.State.LIGHT_ATTACK_1 and new_state == player.State.LIGHT_ATTACK_2:
		return true
	if player.state == player.State.LIGHT_ATTACK_2 and new_state == player.State.LIGHT_ATTACK_1:
		return true
	if new_state == player.State.HEAVY_ATTACK:
		return true
	return false

func take_damage(player, damage, damage_source_pos_x= -99999, knockback_pow=150):
	if player.i_frame > 0:
		return 0
	player.current_hp = player.current_hp-damage if player.current_hp-damage > 0 else 0
	if player.current_hp == 0:
		player.die()
	print("Player just take damage, remaining hp is ",player.current_hp)
	player.i_frame = player.max_i_frame
	player.just_take_damage = player.max_i_frame * 0.8
	if damage_source_pos_x != -99999:
		player.change_state(player.State.BOUNCE)
		player.velocity.y = -knockback_pow
		player.velocity.x = -knockback_pow if player.position.x < damage_source_pos_x else knockback_pow
		player.position.y -= 5
		player.state_lock_time = 0.2
	return damage
