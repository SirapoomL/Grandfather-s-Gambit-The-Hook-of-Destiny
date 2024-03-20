extends RigidBody2D
class_name GroundEnemy

var floating_text = preload("res://scene/utils/floating_text.tscn")

var speed = 60
var player_chase = false
var player = null
var hp = 50
var exp = 10


func _physics_process(delta):
	global_position.y += 980 *delta
	if player_chase && ((player.position.x - position.x) < -40 || (player.position.x - position.x) > 80):
		if (player.position.x > position.x):
			position.x += speed*delta
		else:
			position.x -= speed*delta
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
	if (body.name == 'Player'):
		player = null
		player_chase = false
	#$AnimatedSprite2D.play("spirit_idle")


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	pass # Replace with function body.
	
func hit(damage):
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
