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
		else: player.hang_time = player.hang_time - delta
		if player.is_on_floor():
			player.hang_time = 0.1
			player.air_attack_qouta = 3
			player.velocity.x = 0
			player.change_state(player.State.IDLE)
			player.jump_state = 0
		if GameInputMapper.is_action_pressed("move_right"):
			player.state = player.State.RUN
			player.velocity.x = player.speed
			#player.set_deferred("rotation", 0)
		if GameInputMapper.is_action_pressed("move_left"):
			player.state = player.State.RUN
			player.velocity.x = -player.speed
	if player.state in player.ATTACK_STATE:
		player.velocity.y = 0
		player.velocity.x = 0
		if player.is_on_floor():
			player.hang_time = 0.1
			player.air_attack_qouta = 3
			player.velocity.x = 0
			player.jump_state = 0
			if GameInputMapper.is_action_pressed("move_right"):
				player.velocity.x = player.speed
				#player.set_deferred("rotation", 0)
			if GameInputMapper.is_action_pressed("move_left"):
				player.velocity.x = -player.speed
	match player.state:
		player.State.JUST_HOOKED:
			player.change_state(player.State.HOOKING)
		player.State.SWING:
			if player.is_on_floor():
				player.velocity.x = 0
				player.change_state(player.State.IDLE)
				player.jump_state = 0
				return
			var radius = player.position - player.swing_hook.position
			if player.velocity.length() != 0.0:
				player.velocity = player.velocity.project(player.velocity - player.velocity.project(radius))
			var g = Vector2(0, player.gravity)
			var cent_acc = -(radius.normalized() * (player.velocity.dot(player.velocity) /  pow(radius.length(), 1))) * 0.50
			var player_acc: Vector2 = Vector2(0,0)
			if GameInputMapper.is_action_pressed("move_right"):
				player_acc.x = player.hook_acc
			if GameInputMapper.is_action_pressed("move_left"):
				player_acc.x = -player.hook_acc
			var tangent_player_acc = player_acc - player_acc.project(radius) 
			var acc = g - g.project(radius) + cent_acc + tangent_player_acc
			player.velocity += acc * delta

	if GameInputMapper.is_action_just_pressed("jump") and player.jump_state < player.jump_quota:
		player.hang_time = 0
		player.change_state(player.State.JUMP)
		player.jump_state += 1
		player.velocity.y = player.jump_force

func process_collision(player, _delta):
	# Handle collision logic here
	for i in player.get_slide_collision_count():
		var collision = player.get_slide_collision(i)
		if collision.get_collider() is Enemy or collision.get_collider() is GroundEnemy:
			if player.state == player.State.HOOKING:
				print("hit")
				player.kill.emit(collision.get_collider())
				collision.get_collider().queue_free()
			# else:
			# 	player.hide()
			# 	player.hit.emit()
			# 	player.change_state(player.State.DEAD)
			# 	player.get_node("CollisionShape2D").set_deferred("disabled", true)
		elif player.state == player.State.HOOKING:
			player.change_state(player.State.IDLE)
			player.velocity.y = 0

func process_animation(player,_delta):
	var state_machine = player.get_node("AnimationTree").get("parameters/playback")
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
	#var anim = player.get_node("AnimationPlayer")
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
