extends RigidBody2D
class_name GroundEnemy

var floating_text = preload("res://scene/utils/floating_text.tscn")
var player_chase = false
var player = null

# You can adjust monster's config here 
var speed = 60
var hp = 50
var exp = 10
var GRAVITY = true

# Distance between player and mob for attack range
var left_dir_range = -40
var right_dir_range = 80


func _physics_process(delta):
	if GRAVITY:
		global_position.y += 980 * delta
	if player_chase:
		if not _check_in_attack_range(left_dir_range, right_dir_range):
			if (player.position.x > position.x):
				position.x += speed * delta
			else:
				position.x -= speed * delta
				
			# Make spirit fly towards player
			if not GRAVITY && (player.position.y > position.y):
				position.y += speed * delta
			elif not GRAVITY && (player.position.y < position.y):
				position.y -= speed * delta
			
			$AnimatedSprite2D.play("spirit_move")
			
			# Flip spirit face direction
			if (player.position.x - position.x) < 0:
				$AnimatedSprite2D.flip_h = true
			elif (player.position.x - position.x) > 0:
				$AnimatedSprite2D.flip_h = false

		# Spirit in attack range (stop spirit movement)
		else:
			## TODO attack player function
			$AnimatedSprite2D.play("spirit_attack")
	else:
		$AnimatedSprite2D.play("spirit_idle")


# TODO make it cant see people when the path is blocked
func _on_detection_area_body_entered(body):
	if (body.name == 'Player'):
		player = body
		player_chase = true


func _on_detection_area_body_exited(body):
	if (body.name == 'Player'):
		player = null
		player_chase = false


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	pass # Replace with function body.
	
	
func _check_in_attack_range(left_dir_range, right_dir_range):
	return player_chase && \
	not ((player.position.x - position.x) < left_dir_range || (player.position.x - position.x) > right_dir_range)  && \
	not ((player.position.y - position.y) < left_dir_range || (player.position.y - position.y) > right_dir_range)
	
	
func hit(damage, knockback=30):
	# Add knockback when getting hit
	if (player.position.x > position.x):
		position.x -= knockback
	else:
		position.x += knockback
	
	hp -= damage
	var text = floating_text.instantiate()
	text.amount = damage
	add_child(text)

	#get_tree().root.add_child(text)
	if hp <= 0:
		return [damage, exp]
	return [damage, 0]
	
	
func _self_kill():
	queue_free()
	pass
