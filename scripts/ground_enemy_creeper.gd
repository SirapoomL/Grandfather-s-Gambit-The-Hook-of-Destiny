extends RigidBody2D
class_name GroundEnemyCreeper

var floating_text = preload("res://scene/utils/floating_text.tscn")
var enemy_explosion_particle = preload("res://scene/enemy/enemy_explosion.tscn")
var player_chase = false
var player = null
var offset = 5

# You can adjust monster's config here 
var speed = 50
var hp = 70
var exp = 25
var kaboom_state = false

# NOTE Set GRAVITY to false to make creeper levitate toward player
var GRAVITY = true

# Distance between player and mob for attack range
var left_dir_range = -35
var right_dir_range = 75


# TODO: Creeper go KA-BOOM
func _physics_process(delta):
	$Particles/sparkle.visible = false

	global_rotation = 0
	if player_chase:
		if not _check_in_attack_range(left_dir_range, right_dir_range):
			$AnimatedSprite2D.play("creeper_move")
			$Particles/sparkle.global_position = player.position
			
			# Move creeper in x-axis
			if (player.position.x > position.x):
				position.x += speed * delta
			else:
				position.x -= speed * delta
				
			# Make creeper levitating towards player
			if not GRAVITY && (player.position.y > position.y):
				position.y += speed * delta
			elif not GRAVITY && (player.position.y < position.y):
				position.y -= speed * delta
			
			# Flip creeper face direction
			if (player.position.x - position.x) < offset:
				$AnimatedSprite2D.flip_h = true
				$Particles/sparkle.flip_h = true
				$Particles/sparkle.position.x += offset
			elif (player.position.x - position.x) > offset:
				$AnimatedSprite2D.flip_h = false
				$Particles/sparkle.flip_h = false
				$Particles/sparkle.position.x -= offset

		# Player is in creeper's attack range (stop creeper movement)
		else:
			$AnimatedSprite2D.play("creeper_attack")
			attack_player(player, 3)
	else:
		$AnimatedSprite2D.play("creeper_idle")


func _on_detection_area_body_entered(body):
	if (body.name == 'Player'):
		player = body
		player_chase = true
		
		# prevent rigidbody being affected by colliding with Player
		add_collision_exception_with(body)
	
	# prevent rigidbody being affected by colliding with ground monster
	elif (body.name.begins_with('Ground_Enemy')):
		add_collision_exception_with(body)
	else:
		print("detect", body.name)


func _on_detection_area_body_exited(body):
	if (body.name == 'Player'):
		player = null
		player_chase = false
	
	
func _check_in_attack_range(left_dir_range, right_dir_range):
	return player_chase && \
	not ((player.position.x - position.x) < left_dir_range || (player.position.x - position.x) > right_dir_range)  && \
	not ((player.position.y - position.y) < left_dir_range || (player.position.y - position.y) > right_dir_range)


func hit(damage, knockback=30):
	# Add knockback when getting hit
	if (player.position.x > position.x):
		position.x -= knockback + damage / 2
	else:
		position.x += knockback + damage / 2
		
	# Flash color for a fraction of a second when getting hit
	modulate = Color(60.0, 60.0, 60.0, 255.0)
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	# Decrease hitpoint and popping text
	hp -= damage
	var text = floating_text.instantiate()
	text.amount = damage
	add_child(text)

	if hp <= 0:
		return [damage, exp]
	
	return [damage, 0]
	
	
func attack_player(body, damage=5):
	if (body.name == 'Player'):
		
		if hp >= 35:
			$AttackSound.play()
			$Particles/sparkle.visible = true
			$Particles/sparkle.play("default")
			player.get_node("CombatHandler").take_damage(player, damage, position.x)
		else:
			kaboom_state = true
			
			# TODO make it blinking
			for i in range(10):
				modulate = Color(60.0, 60.0, 60.0, 255.0)
				await get_tree().create_timer(0.2).timeout
				modulate = Color.WHITE
			
			# KA-BOOM!!
			player.get_node("CombatHandler").take_damage(player, 25, position.x)
			_self_kill()


func _self_kill():
	var effect = enemy_explosion_particle.instantiate()
	effect.global_position = global_position
	
	# NOTE set explosion smoke
	effect.smoke = true
	get_tree().current_scene.add_child(effect)
	queue_free()
