extends Node
class_name player_movement

func process(player, delta):
	process_movement(player, delta)
	player.move_and_slide()
	process_collision(player, delta)
	process_animation(player, delta)
	
func strafe(player, delta, direction, factor):
	# direction 1 = right, -1 = left
	var new_v_x = move_toward(player.velocity.x, direction * player.speed, player.speed * factor * delta)
	if direction > 0:
		player.velocity.x = max(new_v_x, player.velocity.x)
	else:
		player.velocity.x = min(new_v_x, player.velocity.x)

func process_gravity(player, delta, k = 1):
	player.velocity.y += player.gravity * delta * k
	
func process_gravity_with_hang_time(player, delta, k = 0.1):
	if player.hang_time < 0:
		process_gravity(player, delta)
	else:
		player.hang_time = player.hang_time - delta
		process_gravity(player, delta, k)
		
func process_normal_state(player, delta):
	process_gravity_with_hang_time(player, delta)
	if player.is_on_floor():
		player.hang_time = 0.1
		# slide if gliding
		if player.state == player.State.GLIDE && player.velocity.x != 0:
			player.velocity.x = move_toward(player.velocity.x, 0, 1000 * delta)
		else:
			player.velocity.x = 0
			player.change_state(player.State.IDLE)
		player.jump_state = 0
		
	if GameState.is_cutscene():
		return
	
	if GameInputMapper.is_action_pressed("move_right"):
		if player.state != player.State.GLIDE:
			player.change_state(player.State.RUN)
		if player.is_on_floor():
			# if sliding, do nothing
			if player.state != player.State.GLIDE:
				player.velocity.x = player.speed
		else:
			var strafe_factor = 5 if player.state == player.State.GLIDE else 7.5
			strafe(player, delta, 1, strafe_factor)
		player.face_left = false
		#player.set_deferred("rotation", 0)
	if GameInputMapper.is_action_pressed("move_left"):
		if player.state != player.State.GLIDE:
			player.change_state(player.State.RUN)
		if player.is_on_floor():
			# if sliding, do nothing
			if player.state != player.State.GLIDE:
				player.velocity.x = -player.speed
		else:
			var strafe_factor = 5 if player.state == player.State.GLIDE else 7.5
			strafe(player, delta, -1, strafe_factor)
		player.face_left = true

func process_normal_hook_state(player, delta):
	if is_instance_valid(player.normal_hook):
		print("hook valid")
		var direction = (player.normal_hook.position - player.position).normalized()
		player.set_velocity(direction * player.hook_speed)
		if (player.position - player.normal_hook.position).dot(player.velocity) > 0:
			player.change_state(player.State.IDLE)
func process_movement(player, delta):
	#print(player.state)
	# Handle movement logic here
	if player.state in player.NORMAL_STATE:
		process_normal_state(player, delta)
	if player.state in player.ATTACK_STATE:
		if player.state != player.State.SWING_ATTACK:
			process_gravity(player, delta, 0.1)
			player.velocity.x = 0
		elif is_instance_valid(player.normal_hook):
			process_normal_hook_state(player, delta)
		else:
			process_normal_state(player, delta)
	if player.state in player.NORMAL_HOOK_STATE:
		process_normal_hook_state(player, delta)
	match player.state:
		#player.State.JUST_HOOKED:
			#player.change_state(player.State.HOOKING)
		#player.State.HOOKING:
			#if is_instance_valid(player.normal_hook):
				## calculate velocity towards hook (like pulling to it)
				#var direction = (player.normal_hook.position - player.position).normalized()
				#player.set_velocity(direction * player.hook_speed)
				##player.velocity += (direction * player.hook_power * delta)
				## TODO: discuss about the IF below later.
				#if (player.position - player.normal_hook.position).dot(player.velocity) > 0:
					#player.change_state(player.State.IDLE)
			
		# player.State.HOOKING:
		# 	if (player.position - player.normal_hook.position).dot(player.velocity) > 0:
		#		player.change_state(player.State.IDLE)
		# player.State.JUST_HOOKED:
		#	player.change_state(player.State.HOOKING)
		
		player.State.WALL_HOOK:
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
			process_gravity(player, delta)
			
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
	if player.state in player.UNAFFECTED_BY_INPUT:
		if player.state == player.State.BOUNCE:
			process_gravity(player, delta)
			if player.is_on_floor():
				#pass
				player.change_state(player.State.IDLE)
				print("on floor")
		if player.state == player.State.CUT_SCENE:
			process_gravity(player, delta)
		return
	if GameInputMapper.is_action_just_pressed("jump") and (player.jump_state < player.jump_quota || player.state == player.State.SWING || player.state == player.State.HOOKING):
		player.hang_time = 0
		player.change_state(player.State.JUMP)
		if player.state != player.State.SWING && player.state not in player.NORMAL_HOOK_STATE:
			player.jump_state += 1
		player.velocity.y = player.jump_force

func process_collision(player, _delta):
	# Handle collision logic here
	for i in player.get_slide_collision_count():
		var collision = player.get_slide_collision(i)
		if collision.get_collider() is Hook:
			player.change_state(player.State.IDLE)
		if collision.get_collider() is Enemy or collision.get_collider() is GroundEnemySpirit or collision.get_collider() is GroundEnemyCreeper:
			if player.state in player.NORMAL_HOOK_STATE:
				print("hit")
				player.kill.emit(collision.get_collider())
				collision.get_collider().queue_free()
			else:
				pass
		# collide with terrain
		elif player.state in player.NORMAL_HOOK_STATE: 
			# check if collide is wall
			var normal = collision.get_normal()
			if collision.get_collider() is StaticHookTerrain and (normal.x == 1 or normal.x == -1) and GameInputMapper.is_action_pressed("hold_wall"):
				player.face_left = normal.x > 0
				player.change_state(player.State.WALL_HOOK)		
			elif not player.is_on_floor():
				#player.velocity.y = 0
				player.change_state(player.State.IDLE)
			elif player.velocity == Vector2.ZERO:
				player.change_state(player.State.IDLE)
			
func process_animation(player,_delta):
	if player.just_take_damage < 0:
		#print("hiding")
		player.hide()
	else:
		#print("not hiding")
		player.show()
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
			if player.is_on_floor():
				state_machine.travel("slide")
			else:
				state_machine.travel("swing")
		player.State.HOLD_HOOK:
			state_machine.travel("swing")
		player.State.SWING:
			state_machine.travel("swing")
		player.State.SWING_ATTACK:
			state_machine.travel("swing_attack")
		player.State.GLIDE:
			if player.is_on_floor():
				state_machine.travel("slide")
			else : state_machine.travel("swing")
		player.State.WALL_HOOK:
			state_machine.travel("wall_hook")
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
