extends Node
class_name LevelManager

signal start_cutscene
signal end_cutscene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_minotaur_boss_room_boss_room_entered():
	if !GameState.minotaur_dead and is_instance_valid($Minotaur):
		$Minotaur.action()
		GameState.set_current_state(GameState.State.CUT_SCENE)
		print("setting cutscene")


func _on_minotaur_death():
	GameState.minotaur_dead = true
	print("congrats")