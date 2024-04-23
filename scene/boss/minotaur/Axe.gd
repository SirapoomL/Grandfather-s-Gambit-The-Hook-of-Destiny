extends Area2D

@export var minotaur : Minotaur

const ATTACKING_STATE = [minotaur.State.CLEAVE, minotaur.State.IMPALE, minotaur.State.WHIRLING]

func _ready():
	monitoring = false
	for child in get_children():
		if(child is CollisionShape2D):
			child.disabled = true
	minotaur.connect("facing_direction", _on_minotaur_facing_direction_changed)

func _on_body_entered(body):
	if body.name != "Player" || minotaur.state not in ATTACKING_STATE:
		return
	var damage : int
	match(minotaur.state):
		minotaur.State.CLEAVE:
			damage = minotaur.cleave_damage
		minotaur.State.IMPALE:
			damage = minotaur.impale_damage
		minotaur.State.WHIRLING:
			damage = minotaur.whirl_damage
	body.get_node("CombatHandler").take_damage(body, damage, minotaur.position.x)

func _on_minotaur_facing_direction_changed(facing_right : bool):
	for child in get_children():
		if(child is CollisionShape2D):
			if(facing_right):
				child.position = child.facing_right_position
			else:
				child.position = child.facing_left_position
