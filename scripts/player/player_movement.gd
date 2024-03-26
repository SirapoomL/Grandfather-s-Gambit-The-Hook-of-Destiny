extends Node
class_name player_movement

func process(player, delta):
	process_movement(player, delta)
	player.move_and_slide()
	process_collision(player, delta)
	process_animation(player, delta)
	
func process_movement(player, delta):
	#print(player.state)
	# Handle movement logic here
	if player.state in player.NORMAL_STATE:
		if player.hang_time < 0:
			player.velocity.y += player.gravity * delta
		else:
			player.hang_time = player.hang_time - delta
			player.velocity.y += player.gravity * delta * 0.1
		if player.is_on_floor():
			player.hang_time = 0.1
			player.air_attack_qouta = 3
			player.velocity.x = 0
			player.change_state(player.State.IDLE)
			player.jump_state = 0
		if GameInputMapper.is_action_pressed("move_right"):
			player.state = player.State.RUN
			player.velocity.x = player.speed
			player.face_left = false
			#player.set_deferred("rotation", 0)
		if GameInputMapper.is_action_pressed("move_left"):
			player.state = player.State.RUN
			player.velocity.x = -player.speed
			player.face_left = true
	if player.state in player.ATTACK_STATE:
		player.velocity.y += player.gravity * delta * 0.1
		player.velocity.x = 0
		#if player.is_on_floor():
			#player.hang_time = 0.1
			#player.air_attack_qouta = 3
			#player.velocity.x = 0
			#player.jump_state = 0
			#if GameInputMapper.is_action_pressed("move_right"):
				#player.velocity.x = player.speed
			#if GameInputMapper.is_action_pressed("move_left"):
				#player.velocity.x = -player.speed
	match player.state:
		#player.State.JUST_HOOKED:
			#player.change_state(player.State.HOOKING)
		player.State.HOOKING:
			if is_instance_valid(player.normal_hook):
				var direction = (player.normal_hook.position - player.position).normalized()
				player.set_velocity(direction * player.hook_speed) 
			
		player.State.WALL_HOOK:
			player.velocity.x = 0
			player.velocity.y = 0
			if GameInputMapper.is_action_just_released("hold_wall") ||GameInputMapper.is_action_pressed_in(["move_right", "move_left", "jump"]):
				print("cancle wall hook")
				player.change_state(player.State.IDLE)
				process_movement(player, delta)
				return
		player.State.SWING:
			if player.is_on_floor():
				player.velocity.x = 0
				player.change_state(player.State.IDLE)
				player.jump_state = 0
				return
				
			# apply gravity
			player.velocity.y += player.gravity * delta
			
			# left/right strafe
			if GameInputMapper.is_action_pressed("move_right"):
				if player.velocity.x < player.speed:
					player.velocity.x = move_toward(player.velocity.x, player.speed, player.speed * delta)
			if GameInputMapper.is_action_pressed("move_left"):
				if player.velocity.x > -player.speed:
					player.velocity.x = move_toward(player.velocity.x, -player.speed, player.speed * delta)
					
			# project velocity
			var hook_direction = (player.position - player.swing_hook.position).normalized()
			if player.velocity.dot(hook_direction) > 0:
				player.velocity = player.velocity.project(hook_direction.orthogonal())

	if GameInputMapper.is_action_just_pressed("jump") and (player.jump_state < player.jump_quota || player.state == player.State.SWING || player.state == player.State.HOOKING):
		player.hang_time = 0
		player.change_state(player.State.JUMP)
		if player.state != player.State.SWING && player.state != player.State.HOOKING:
			player.jump_state += 1
		player.velocity.y = player.jump_force

func process_collision(player, _delta):
	# Handle collision logic here
	for i in player.get_slide_collision_count():
		var collision = player.get_slide_collision(i)
		if collision.get_collider() is Hook:
			player.change_state(player.State.IDLE)
		if collision.get_collider() is Enemy or collision.get_collider() is GroundEnemySpirit:
			if player.state == player.State.HOOKING:
				print("hit")
				player.kill.emit(collision.get_collider())
				collision.get_collider().queue_free()
			else:
				if player.get_node("CombatHandler").take_damage(player, 40) > 0:
					pass # todo: implement bounce on take damage
		elif player.state == player.State.HOOKING:
			if GameInputMapper.is_action_pressed("hold_wall"):
				player.change_state(player.State.WALL_HOOK)
			else:
				#player.change_state(player.State.IDLE)
				pass
			player.velocity.y = 0
func process_animation(player,_delta):
	if player.face_left:
		player.get_node("Sprite2D").flip_h = true
	else:
		player.get_node("Sprite2D").flip_h = false
	var state_machine = player.get_node("AnimationTree").get("parameters/playback")
	#print(player.get_tree().root.get_node(player.get_node("AnimationTree")))
	#player.get_node("AnimationTree").get_animation_player().set_deferred("speed_scale",100)
	#player.get_tree().root.get_node(player.get_node("AnimationTree").get_animation_player()).speed_scale = 0.1 
	match player.state:
		player.State.IDLE:
			state_machine.travel("idle")
		player.State.RUN:
			state_machine.travel("run")
		player.State.JUMP:
			state_machine.travel("run")
		player.State.LIGHT_ATTACK_1:
			state_machine.travel("light_attack_1")
		player.State.LIGHT_ATTACK_2:
			state_machine.travel("light_attack_2")
		player.State.HEAVY_ATTACK:
			state_machine.travel("heavy_attack")
		player.State.HOOKING:
			state_machine.travel("swing")
		player.State.HOLD_HOOK:
			state_machine.travel("swing")
		player.State.SWING:
			state_machine.travel("swing")
		player.State.HOOK_ATTACK:
			state_machine.travel("light_attack_1")
	#var anim = player.get_node("AnimationPlayer")
	#anim.set_speed_scale(200)
	#match player.state:
		#player.State.IDLE:
			#anim.play("idle")
		#player.State.RUN:
			#anim.play("run")
		#player.State.JUMP:
			#anim.play("run")
		#player.State.LIGHT_ATTACK_1:
			#anim.play("run")
		#player.State.LIGHT_ATTACK_2:
			#anim.play("run")
		#player.State.HEAVY_ATTACK:
			#anim.play("heavy_attack")
