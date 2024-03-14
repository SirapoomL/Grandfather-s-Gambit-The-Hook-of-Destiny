extends Node
class_name player_movement

func process(player, delta):
	process_movement(player, delta)
	player.move_and_slide()
	process_collision(player, delta)
	process_animation(player, delta)
	
func process_movement(player, delta):
	# Handle movement logic here
	match player.state:
		player.State.NORMAL:
			player.velocity.y += player.gravity * delta
			if player.is_on_floor():
				player.velocity.x = 0
				player.change_state(player.State.NORMAL)
				player.jump_state = 0
			if GameInputMapper.is_action_pressed("move_right"):
				player.velocity.x = player.speed
				player.set_deferred("rotation", 0)
			if GameInputMapper.is_action_pressed("move_left"):
				player.velocity.x = -player.speed
				player.set_deferred("rotation", -PI)
		player.State.JUST_HOOKED:
			player.change_state(player.State.HOOKING)
		player.State.SWING:
			if player.is_on_floor():
				player.velocity.x = 0
				player.change_state(player.State.NORMAL)
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
		player.change_state(player.State.NORMAL)
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
			else:
				player.hide()
				player.hit.emit()
				player.change_state(player.State.DEAD)
				player.get_node("CollisionShape2D").set_deferred("disabled", true)
		elif player.state == player.State.HOOKING:
			player.change_state(player.State.NORMAL)
			player.velocity.y = 0

func process_animation(player,_delta):
	if player.velocity.x != 0 and player.velocity.y != 0:
		player.get_node("AnimatedSprite2D").play()
	else:
		player.get_node("AnimatedSprite2D").stop()
	if player.velocity.x != 0:
		player.get_node("AnimatedSprite2D").animation = "walk"
		player.get_node("AnimatedSprite2D").flip_v = false
		player.get_node("AnimatedSprite2D").flip_h = player.velocity.x < 0
	elif player.velocity.y != 0:
		player.get_node("AnimatedSprite2D").animation = "jump"
		player.get_node("AnimatedSprite2D").flip_v = player.velocity.y > 0
