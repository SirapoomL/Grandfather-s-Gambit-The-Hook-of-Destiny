extends RigidBody2D
class_name GroundEnemyWorm

var enemy_explosion_particle = preload("res://scene/enemy/enemy_explosion.tscn")
var floating_text = preload("res://scene/utils/floating_text.tscn")
var player_chase = false
var player = null
var offset = 5

# You can adjust monster's config here
var speed = 40
var hp = 125
var exp = 50

# NOTE Set GRAVITY to false to make worm levitate toward player
var GRAVITY = true

# Distance between player and mob for attack range
var left_dir_range = -300
var right_dir_range = 300


func _play_idle_animation():
	$Idle_Sprite2D.visible = true
	$Walk_Sprite2D.visible = false
	$Attack_Sprite2D.visible = false
	$Death_Sprite2D.visible = false
	$AnimationPlayer.play('idle')
	
	
func _play_walk_animation():
	$Idle_Sprite2D.visible = false
	$Walk_Sprite2D.visible = true
	$Attack_Sprite2D.visible = false
	$Death_Sprite2D.visible = false
	$AnimationPlayer.play('walk')
	
	
func _play_attack_animation():
	$Idle_Sprite2D.visible = false
	$Walk_Sprite2D.visible = false
	$Attack_Sprite2D.visible = true
	$Death_Sprite2D.visible = false
	$AnimationPlayer.play('attack')


func _physics_process(delta):
	global_rotation = 0
	if player_chase:
		if not _check_in_attack_range(left_dir_range, right_dir_range):
			# Move worm in x-axis
			if $AnimationPlayer.get_current_animation() != "attack":
				_play_walk_animation()
				if (player.position.x > position.x):
					position.x += speed * delta
				else:
					position.x -= speed * delta
				
				# Make worm levitating towards player
				if not GRAVITY && (player.position.y > position.y):
					position.y += speed * delta
				elif not GRAVITY && (player.position.y < position.y):
					position.y -= speed * delta
			
			# Flip worm face direction
			if (player.position.x - position.x) < offset:
				$Idle_Sprite2D.flip_h = true
				$Walk_Sprite2D.flip_h = true
				$Attack_Sprite2D.flip_h = true
				$Death_Sprite2D.flip_h = true
			elif (player.position.x - position.x) > offset:
				$Idle_Sprite2D.flip_h = false
				$Walk_Sprite2D.flip_h = false
				$Attack_Sprite2D.flip_h = false
				$Death_Sprite2D.flip_h = false

		# Player is in worm's attack range (stop worm movement)
		else:
			# Flip worm face direction
			if (player.position.x - position.x) < offset:
				$Attack_Sprite2D.flip_h = true
			elif (player.position.x - position.x) > offset:
				$Attack_Sprite2D.flip_h = false
			
			if $AttackCooldown.is_stopped():
				_play_attack_animation()
				attack_player(player, 10)
				$AttackCooldown.start()
	else:
		_play_idle_animation()


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
	not ((player.position.x - position.x) < left_dir_range || (player.position.x - position.x) > right_dir_range)


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
	

# TODO add fireball animation range(-300, 300)
# TODO add fireball sound
# TODO if fireball hit player, deal damage
func attack_player(body, damage=5):
	if (body != null) and (body.name == 'Player'):
		#$AttackSound.play()
		#$Particles/sparkle.visible = true
		#$Particles/sparkle.play("default")
		if abs(player.position.y - position.y) < 20:
			player.get_node("CombatHandler").take_damage(player, damage, position.x)


func _self_kill(smoke=false):
	var effect = enemy_explosion_particle.instantiate()
	effect.global_position = global_position
	
	# NOTE set explosion smoke
	effect.smoke = smoke
	get_tree().current_scene.add_child(effect)
	queue_free()
