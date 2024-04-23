extends Area2D

@export var gorilla : Gorilla

const ATTACKING_STATE = [
	gorilla.State.SLAM, gorilla.State.CHARGE, gorilla.State.COUNTER, 
	gorilla.State.DIVE_MIDAIR, gorilla.State.DIVE_LANDING,
	gorilla.State.TRIPLE_DIVE_MIDAIR, gorilla.State.TRIPLE_DIVE_LANDING]

func _ready():
	monitoring = false
	for child in get_children():
		if(child is CollisionShape2D):
			child.disabled = true
	gorilla.connect("facing_direction", _on_gorilla_facing_direction_changed)

func _on_body_entered(body):
	if body.name != "Player" || gorilla.state not in ATTACKING_STATE:
		return
	var damage : int
	var knockback : int = 150
	match(gorilla.state):
		gorilla.State.SLAM:
			damage = gorilla.slam_damage
			knockback = 300
		gorilla.State.CHARGE:
			damage = gorilla.charge_damage
		gorilla.State.COUNTER:
			damage = gorilla.counter_damage
			knockback = 300
		gorilla.State.DIVE_MIDAIR:
			damage = gorilla.dive_midair_damage
		gorilla.State.DIVE_LANDING:
			damage = gorilla.dive_damage
			knockback = 600
		gorilla.State.TRIPLE_DIVE_MIDAIR:
			damage = gorilla.triple_dive_midair_damage
		gorilla.State.TRIPLE_DIVE_LANDING:
			damage = gorilla.triple_dive_damage
			knockback = 600
	body.get_node("CombatHandler").take_damage(body, damage, gorilla.position.x, knockback)

func _on_gorilla_facing_direction_changed(facing_right : bool):
	for child in get_children():
		if(child is CollisionShape2D):
			if(facing_right):
				child.position = child.facing_right_position
			else:
				child.position = child.facing_left_position
