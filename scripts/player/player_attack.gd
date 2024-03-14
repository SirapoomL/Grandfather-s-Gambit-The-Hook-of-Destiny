extends Node
class_name player_attack

func process(player, delta):
	if GameInputMapper.is_action_pressed("light_attack"):
		player.get_node("AnimatedSprite2D/AttackBox/LightAttackCollisionShape").set_deferred("disabled", false)
	elif GameInputMapper.is_action_pressed("heavy_attack"):
		player.get_node("AnimatedSprite2D/AttackBox/HeavyAttackCollisionShape").set_deferred("disabled", false)
	else:
		player.get_node("AnimatedSprite2D/AttackBox/LightAttackCollisionShape").set_deferred("disabled", true)
		player.get_node("AnimatedSprite2D/AttackBox/HeavyAttackCollisionShape").set_deferred("disabled", true)

#func _on_attack_box_body_entered(player, body):
	#print("attack")
	#if body is Enemy or body is GroundEnemy:
		#print("hit")
		#player.kill.emit(body)
		#body.queue_free()
