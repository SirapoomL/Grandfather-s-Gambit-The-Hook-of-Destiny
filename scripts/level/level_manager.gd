extends Node
class_name LevelManager

signal start_cutscene
signal end_cutscene

enum MusicState {MAIN, BOSS}

var music_state = MusicState.MAIN

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func pause_music():
	get_current_music_player().stream_paused = true
	
func resume_music():
	get_current_music_player().stream_paused = false
	
func play_music(state: MusicState):
	match state:
		MusicState.MAIN:
			music_state = state
			$BossMusic.stop()
			$MainMusic.play()
		MusicState.BOSS:
			music_state = state
			$MainMusic.stop()
			$BossMusic.play()

func get_current_music_player():
	match music_state:
		MusicState.MAIN:
			return $MainMusic
		MusicState.BOSS:
			return $BossMusic
			
func stop_music():
	get_current_music_player().stop()

func _on_minotaur_boss_room_boss_room_entered():
	if !GameState.minotaur_dead and is_instance_valid($Minotaur):
		play_music(MusicState.BOSS)
		$Minotaur.action()
		


func _on_minotaur_death():
	GameState.minotaur_dead = true
	print("congrats")
	play_music(MusicState.MAIN)


func _on_gorilla_dead():
	$VictoryText.show()
	play_music(MusicState.MAIN)


func _on_gorilla_boss_room_gorilla_room_entered():
	if is_instance_valid($Gorilla):
		play_music(MusicState.BOSS)
		$Gorilla.action()
