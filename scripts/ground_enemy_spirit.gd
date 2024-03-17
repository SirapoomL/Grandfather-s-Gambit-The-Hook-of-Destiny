extends RigidBody2D
class_name GroundEnemy

var speed = 60
var player_chase = false
var player = null


func _physics_process(delta):
	if player_chase:
		position.x += (player.position.x - position.x) / speed
		#position.y += (player.position.y - position.y) / speed # NOTE uncomment this to make spirit fly!
		$AnimatedSprite2D.play("spirit_move")
		
		if (player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("spirit_idle")


func _on_detection_area_body_entered(body):
	if (body.name == 'Player'):
		player = body
		player_chase = true
	#$AnimatedSprite2D.play("spirit_attack")


func _on_detection_area_body_exited(body):
	player = null
	player_chase = false
	#$AnimatedSprite2D.play("spirit_idle")


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	pass # Replace with function body.
	
	
func _self_kill():
	queue_free()
	pass
